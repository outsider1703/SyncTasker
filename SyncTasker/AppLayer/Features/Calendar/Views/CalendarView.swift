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
    static let monthTitleScale: CGFloat = 1.2
    static let monthTitleOffset: CGFloat = -30
    static let titleAnimationDuration: Double = 0.3
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
    @State private var viewType: CalendarViewType = .month
    @State private var isTitleAnimating = false
    
    private let gridItems = Array(repeating: GridItem(.flexible()), count: Constants.columns)
    
    // MARK: - Initialization
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(monthTitle)
                .font(Theme.Typography.headlineFont)
                .padding(.vertical)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(isTitleAnimating ? 1.1 : 1.0)
                .opacity(isTitleAnimating ? 0.5 : 1.0)
                .animation(.easeInOut(duration: Constants.titleAnimationDuration), value: isTitleAnimating)
                .onTapGesture {
                    withAnimation {
                        isTitleAnimating = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                            viewType = .year
                            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                                isTitleAnimating = false
                            }
                        }
                    }
                }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    switch viewType {
                    case .month:
                        MonthView(
                            date: selectedDate,
                            selectedDate: $selectedDate
                        )
                        .frame(width: geometry.size.width, alignment: .leading)
                    case .year:
                        YearView(selectedDate: $selectedDate) { date in
                            withAnimation {
                                isTitleAnimating = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                                    selectedDate = date
                                    viewType = .month
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                                        isTitleAnimating = false
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private var monthTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = viewType == .month ? "MMMM yyyy" : "yyyy"
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
        
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(getDaysInMonth()) { dayItem in
                        if let date = dayItem.date {
                            DayView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), onTap: { withAnimation { selectedDate = date } })
                        }
                    }
                }
                .padding(.all, 16)
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
        
        private func getMonthTitle(for date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
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
    
    // MARK: - YearView
    struct YearView: View {
        @Binding var selectedDate: Date
        let onMonthSelected: (Date) -> Void
        private let calendar = Calendar.current
        private let weekDayColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: monthColumns, spacing: 20) {
                    ForEach(getMonthsInYear(), id: \.self) { month in
                        Button(action: { onMonthSelected(month) }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(getMonthTitle(for: month))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                let days = generateDaysForMonth(month)
                                ForEach(0..<6) { week in
                                    HStack(spacing: 2) {
                                        ForEach(0..<7) { weekday in
                                            let index = week * 7 + weekday
                                            if index < days.count {
                                                let day = days[index]
                                                if let date = day.date {
                                                    let isCurrentDate = calendar.isDate(date, inSameDayAs: selectedDate)
                                                    RoundedRectangle(cornerRadius: 1)
                                                        .frame(width: 16, height: 16)
                                                        .background(isCurrentDate ? Theme.Colors.primary.opacity(0.2) : Color.clear)
                                                } else {
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: 16, height: 16)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        
        // MARK: - Helper Functions
        private struct DayItem {
            let date: Date?
            let dayNumber: Int?
        }
        
        private func generateDaysForMonth(_ month: Date) -> [DayItem] {
            let components = calendar.dateComponents([.year, .month], from: month)
            guard let firstDayOfMonth = calendar.date(from: components),
                  let daysRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
            else { return [] }
            
            var days: [DayItem] = []
            
            // Get the weekday of the first day (1-7, where 1 is Monday)
            let firstWeekday = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7 + 1
            
            // Add empty days for the first week
            for _ in 1..<firstWeekday {
                days.append(DayItem(date: nil, dayNumber: nil))
            }
            
            // Add all days in the month
            for day in daysRange {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                    days.append(DayItem(date: date, dayNumber: day))
                }
            }
            
            // Fill the remaining days in the last week
            let remainingDays = 42 - days.count // 6 weeks * 7 days = 42
            for _ in 0..<remainingDays {
                days.append(DayItem(date: nil, dayNumber: nil))
            }
            
            return days
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
            // Calculate weekday index (0-6) where Sunday is 0
            return (calendar.component(.weekday, from: firstDayOfMonth) + 6) % 7
        }
        
        private func getDaysInMonth(_ date: Date) -> Int {
            guard let range = calendar.range(of: .day, in: .month, for: date) else { return 0 }
            return range.upperBound - range.lowerBound
        }
        
        private var startOfYear: Date {
            let components = calendar.dateComponents([.year], from: selectedDate)
            return calendar.date(from: components) ?? selectedDate
        }
    }
}
