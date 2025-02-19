//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    static let navigationTitle = "Calendar"
    static let taskListButtonTitle = "Open Task List"
    static let taskListIcon = "list.bullet"
    static let columns = 1
    static let monthsToLoad = 100

}

// MARK: - CalendarViewType
enum CalendarViewType: String, CaseIterable {
    case month = "Month"
    case year = "Year"
}

struct CalendarView: View {
    // MARK: - ViewModel
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Properties
    private let calendar = Calendar.current
    @State private var selectedDate = Date()
    @State private var currentPage = Constants.monthsToLoad / 2
    @State private var viewType: CalendarViewType = .month
    
    private let gridItems = Array(repeating: GridItem(.flexible()), count: Constants.columns)
    
    // MARK: - Initialization
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { viewModel.navigateToTaskList() }) {
                Label(Constants.taskListButtonTitle, systemImage: Constants.taskListIcon)
                    .font(Theme.Typography.headlineFont)
                    .foregroundColor(Theme.Colors.primary)
                    .padding()
                    .background(Theme.Colors.background)
                    .cornerRadius(Theme.Layout.cornerRadius)
            }
            
            Picker("View Type", selection: $viewType) {
                ForEach(CalendarViewType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Text(monthTitle)
                .font(Theme.Typography.headlineFont)
                .padding(.vertical)
            
            switch viewType {
            case .month:
                MonthTabView(
                    currentPage: $currentPage,
                    selectedDate: $selectedDate
                )
            case .year:
                YearView(selectedDate: $selectedDate)
            }
        }
    }
    
    // MARK: - Helper Functions
    private var monthTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private func getDate(for monthOffset: Int) -> Date {
        calendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }
    
    // MARK: - MonthView
    struct MonthView: View {
        private let calendar = Calendar.current
        let date: Date
        @Binding var selectedDate: Date
        
        @State private var viewHeight: CGFloat = 0
        @State private var selectedItemFrame: CGRect = .zero
        @State private var scrollOffset: CGFloat = 0
        
        private let gridItems = [GridItem(.flexible())]
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 8) {
                        ForEach(getDaysInMonth()) { dayItem in
                            if let date = dayItem.date {
                                DayView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), onTap: {
                                    withAnimation {
                                        selectedDate = date
                                    }
                                })
                                .id(dayItem.id)
                                .background(
                                    GeometryReader { itemGeometry in
                                        Color.clear
                                            .onAppear {
                                                if calendar.isDate(date, inSameDayAs: Date()) {
                                                    let frame = itemGeometry.frame(in: .named("ScrollView"))
                                                    selectedItemFrame = frame
                                                    
                                                    // Calculate offset to center the selected date
                                                    let targetOffset = frame.minY - (geometry.size.height - frame.height) / 2
                                                    scrollOffset = max(0, targetOffset)
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
                .coordinateSpace(name: "ScrollView")
                .onAppear {
                    // Set initial scroll position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
                                setInitialScroll(geometry: geometry)
                            }
                        }
                    }
                }
            }
        }
        
        private func setInitialScroll(geometry: GeometryProxy) {
            let screenHeight = UIScreen.main.bounds.height
            let contentOffset = selectedItemFrame.minY - (screenHeight - selectedItemFrame.height) / 2
            scrollOffset = max(0, contentOffset)
        }
        
        private func getDaysInMonth() -> [DayItem] {
            let interval = calendar.dateInterval(of: .month, for: date)!
            let firstDay = interval.start
            
            let firstWeekday = calendar.component(.weekday, from: firstDay)
            
            var days: [DayItem] = []
            for i in 0..<(firstWeekday - 1) {
                days.append(DayItem(id: i, date: nil))
            }
            
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
            for day in 1...daysInMonth {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                    days.append(DayItem(id: day + firstWeekday - 1, date: date))
                }
            }
            
            return days
        }
        
        private struct DayItem: Identifiable {
            let id: Int
            let date: Date?
        }
    }
    
    // MARK: - DayView
    struct DayView: View {
        let date: Date
        let isSelected: Bool
        let onTap: () -> Void
        private let calendar = Calendar.current
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.white
                    .frame(width: 150, height: 150)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                Text("\(calendar.component(.day, from: date))")
                    .font(Theme.Typography.bodyFont)
                    .padding(8)
            }
            .frame(width: 150, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.Colors.primary : .white)
            )
            .foregroundColor(isSelected ? .white : Theme.Colors.primary)
            .onTapGesture {
                onTap()
            }
        }
    }
    
    // MARK: - MonthTabView
    struct MonthTabView: View {
        @Binding var currentPage: Int
        @Binding var selectedDate: Date
        
        var body: some View {
            TabView(selection: $currentPage) {
                ForEach(-Constants.monthsToLoad/2...Constants.monthsToLoad/2, id: \.self) { monthOffset in
                    MonthView(
                        date: getDate(for: monthOffset),
                        selectedDate: $selectedDate
                    )
                    .tag(monthOffset + Constants.monthsToLoad/2)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentPage) { newValue in
                selectedDate = getDate(for: newValue - Constants.monthsToLoad/2)
            }
        }
        
        private func getDate(for monthOffset: Int) -> Date {
            Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
        }
    }
    
    // MARK: - YearView
    struct YearView: View {
        @Binding var selectedDate: Date
        private let calendar = Calendar.current
        private let weekDayColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: monthColumns, spacing: 20) {
                    ForEach(getMonthsInYear(), id: \.self) { month in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getMonthTitle(for: month))
                                .font(.system(size: 14, weight: .semibold))
                            
                            LazyVGrid(columns: weekDayColumns, spacing: 2) {
                                // Empty spaces for alignment
                                ForEach(0..<getFirstWeekdayOfMonth(month), id: \.self) { _ in
                                    Color.clear
                                        .frame(width: 4, height: 4)
                                }
                                
                                // Days of the month
                                ForEach(getDaysInMonth(month)) { dayItem in
                                    DotView(isSelected: calendar.isDate(dayItem.date, inSameDayAs: selectedDate))
                                        .onTapGesture {
                                            selectedDate = dayItem.date
                                        }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        
        private func getMonthsInYear() -> [Date] {
            let interval = calendar.dateInterval(of: .year, for: startOfYear)!
            var months: [Date] = []
            var date = interval.start
            
            while date < interval.end {
                months.append(date)
                date = calendar.date(byAdding: .month, value: 1, to: date)!
            }
            
            return months
        }
        
        private func getMonthTitle(for date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            return formatter.string(from: date)
        }
        
        private func getFirstWeekdayOfMonth(_ date: Date) -> Int {
            let components = calendar.dateComponents([.year, .month], from: date)
            let firstDayOfMonth = calendar.date(from: components)!
            return (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7
        }
        
        private var startOfYear: Date {
            let components = calendar.dateComponents([.year], from: selectedDate)
            return calendar.date(from: components) ?? selectedDate
        }
        
        private struct DayItem: Identifiable {
            let id: Int
            let date: Date
        }
        
        private func getDaysInMonth(_ date: Date) -> [DayItem] {
            let range = calendar.range(of: .day, in: .month, for: date)!
            return range.map { day in
                let components = calendar.dateComponents([.year, .month], from: date)
                var newComponents = components
                newComponents.day = day
                let date = calendar.date(from: newComponents)!
                return DayItem(id: day, date: date)
            }
        }
    }
    
    // MARK: - DotView
    struct DotView: View {
        let isSelected: Bool
        
        var body: some View {
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color.black, lineWidth: 0.5)
                .frame(width: 16, height: 16)
                .background(
                    isSelected ? Color.black : Color.clear
                )
        }
    }
}
