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
            HStack {
                Text("\(calendar.component(.day, from: date))")
                    .font(Theme.Typography.bodyFont)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.Colors.primary : Theme.Colors.background)
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
        private let monthsGridItems = Array(repeating: GridItem(.flexible()), count: 3)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: monthsGridItems, spacing: 16) {
                    let months = Array(0...11)
                    ForEach(months, id: \.self) { monthIndex in
                        Group {
                            if let monthDate = calendar.date(byAdding: .month, value: monthIndex, to: startOfYear) {
                                MiniMonthView(date: monthDate, selectedDate: $selectedDate)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        
        private var startOfYear: Date {
            let components = calendar.dateComponents([.year], from: selectedDate)
            return calendar.date(from: components) ?? selectedDate
        }
    }
}

struct MiniMonthView: View {
    let date: Date
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 4) {
            ForEach(getDaysInMonth()) { dayItem in
                if let date = dayItem.date {
                    Text("\(calendar.component(.day, from: date))")
                        .font(Theme.Typography.captionFont)
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate)
                                      ? Theme.Colors.primary
                                      : Theme.Colors.background)
                        )
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate)
                                         ? .white
                                         : Theme.Colors.primary)
                        .onTapGesture {
                            selectedDate = date
                        }
                } else {
                    Color.clear
                        .frame(height: 20)
                }
            }
        }
    }
    
    private struct DayItem: Identifiable {
        let id: Int
        let date: Date?
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
}
