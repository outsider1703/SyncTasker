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
    static let drawerWidth: CGFloat = UIScreen.main.bounds.width
    static let drawerClosedPosition: CGFloat = UIScreen.main.bounds.width - 40
    static let drawerMidPosition: CGFloat = UIScreen.main.bounds.width / 2
    static let drawerOpenPosition: CGFloat = 0
    static let dragThreshold: CGFloat = 50
}

// MARK: - DrawerPosition
private enum DrawerPosition {
    case closed, mid, open
    
    var offset: CGFloat {
        switch self {
        case .closed: return Constants.drawerClosedPosition
        case .mid: return Constants.drawerMidPosition
        case .open: return Constants.drawerOpenPosition
        }
    }
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
    @State private var drawerOffset: CGFloat = Constants.drawerClosedPosition
    @State private var drawerPosition: DrawerPosition = .closed
    @State private var isDragging = false
    
    private let gridItems = Array(repeating: GridItem(.flexible()), count: Constants.columns)
    
    // MARK: - Initialization
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    switch viewType {
                    case .month:
                        HStack(spacing: 0) {
                            // Left side - MonthView
                            MonthView(date: selectedDate, selectedDate: $selectedDate)
                                .frame(width: geometry.size.width/2)
                                .ignoresSafeArea()
                            
                            // Right side - Month title
                            VStack {
                                Text(monthTitle)
                                    .font(Theme.Typography.headlineFont)
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
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width/2)
                            .padding(.top, 16)
                        }
                        
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
            
            // Update drawer view visibility
            if viewType == .month {
                GeometryReader { geometry in
                    DrawerView()
                        .frame(width: Constants.drawerWidth)
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea()
                        .background(Color.white)
                        .offset(x: drawerOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let translation = value.translation.width
                                    drawerOffset = min(Constants.drawerClosedPosition, max(Constants.drawerOpenPosition, getStartOffset() + translation))
                                }
                                .onEnded { value in
                                    let velocity = value.predictedEndTranslation.width
                                    let nextPosition = calculateNextPosition(velocity: velocity)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        drawerPosition = nextPosition
                                        drawerOffset = nextPosition.offset
                                    }
                                }
                        )
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
    
    private func getStartOffset() -> CGFloat {
        drawerPosition.offset
    }
    
    private func calculateNextPosition(velocity: CGFloat) -> DrawerPosition {
        let currentOffset = drawerOffset
        
        // Учитываем скорость свайпа
        if abs(velocity) > 500 {
            return velocity > 0 ? .closed : .open
        }
        
        // Определяем ближайшую позицию
        let positions = [DrawerPosition.closed, .mid, .open]
        return positions.min(by: { abs($0.offset - currentOffset) < abs($1.offset - currentOffset) }) ?? .closed
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
                .padding(.top, 64)
            }
            .ignoresSafeArea()
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
    
    private struct DrawerView: View {
        var body: some View {
            ZStack(alignment: .leading) {
                Color.white
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                    )
            }
            .shadow(radius: 5)
        }
    }
}
