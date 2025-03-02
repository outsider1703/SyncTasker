//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

struct MonthView: View {
    
    // MARK: - Private Properties
    
    @State private var days: [DayItem] = []
    @State private var months: [Date] = []
    private let monthsToLoad = 12
    
    private var dailyTasks: [Date: [TaskItem]]
    private let calendar = Calendar.current
    private let date: Date
    private let onTaskDropped: (UUID, Date) -> Void
    private let routeToDailySchedule: (Date, [TaskItem]) -> Void
    @State private var visibleMonth: Date?
    @Binding var currentMonth: Date
    
    // MARK: - Initialization
    
    init(
        date: Date,
        selectedDate: Binding<Date>,
        currentMonth: Binding<Date>,
        dailyTasks: [Date: [TaskItem]],
        onTaskDropped: @escaping (UUID, Date) -> Void,
        routeToDailySchedule: @escaping (Date, [TaskItem]) -> Void
    ) {
        self.date = date
        self._currentMonth = currentMonth
        self.onTaskDropped = onTaskDropped
        self.dailyTasks = dailyTasks
        self.routeToDailySchedule = routeToDailySchedule
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            if !days.isEmpty {
                StackedCards(
                    items: days,
                    stackedDisplayCount: 3,
                    opacityDisplayCount: 2,
                    disablesOpacityEffect: false,
                    itemHeight: 150,
                    onMonthChanged: { month in
                        updateMonthTitle(for: month)
                    }
                ) { dayItem in
                    if let date = dayItem.date {
                        DayView(
                            date: date,
                            tasks: getTasksForDate(date),
                            onTap: { routeToDailySchedule(date, getTasksForDate(date)) },
                            onTaskDropped: onTaskDropped
                        )
                    } else if let nextDate = getNextDate(for: dayItem, in: days) {
                        MonthSeparatorView(date: nextDate)
                    }
                }
            }
        }
        .onAppear {
            generateMonths()
            days = getAllMonthsDays()
        }
    }
    
    // MonthSeparatorView component
    private func MonthSeparatorView(date: Date) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return Text(dateFormatter.string(from: date))
            .font(Theme.Typography.headlineFont)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 150)
            .background(Color.white)
    }
    
    // MARK: - Private Methods
    
    private func getTasksForDate(_ date: Date) -> [TaskItem] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let normalizedDate = calendar.date(from: components) else { return [] }
        return dailyTasks[normalizedDate] ?? []
    }
    
    private func generateMonths() {
        let currentDate = date
        months = (-monthsToLoad...monthsToLoad).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: currentDate)
        }
    }
    
    private func getAllMonthsDays() -> [DayItem] {
        guard let firstMonth = months.first, let lastMonth = months.last,
              let startDate = calendar.dateInterval(of: .month, for: firstMonth)?.start,
              let endDate = calendar.dateInterval(of: .month, for: lastMonth)?.end else { return [] }
        
        // Создаем компоненты для всего периода сразу
        var currentDate = startDate
        var idCounter = 0
        var allDays = [DayItem]()
        
        while currentDate < endDate {
            // Проверяем, это первый день месяца или нет
            if calendar.component(.day, from: currentDate) == 1 && currentDate != startDate {
                // Добавляем разделитель между месяцами
                allDays.append(DayItem(id: idCounter, date: nil))
                idCounter += 1
            }
            
            allDays.append(DayItem(id: idCounter, date: currentDate))
            idCounter += 1
            
            // Переходим к следующему дню
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return allDays
    }
    
    private func getNextDate(for item: DayItem, in items: [DayItem]) -> Date? {
        if let index = items.firstIndex(where: { $0.id == item.id }),
           index < items.count - 1,
           let date = items[index + 1].date {
            return date
        }
        return nil
    }
    
    private func updateMonthTitle(for month: Date) {
        // Обновляем месяц только если это новый месяц
        if month != visibleMonth {
            visibleMonth = month
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = month
            }
        }
    }
}

@MainActor
struct StackedCards<Content: View>: View {
    var items: [DayItem]
    var stackedDisplayCount: Int
    var opacityDisplayCount: Int
    var disablesOpacityEffect: Bool
    var itemHeight: CGFloat
    var onMonthChanged: (Date) -> Void
    @ViewBuilder var content: (DayItem) -> Content
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        GeometryReader { itemProxy in
                            content(item)
                                .frame(height: itemHeight)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .opacity(disablesOpacityEffect == true ? 1 : calculateOpacity(geometryProxy))
                                        .scaleEffect(calculateScale(geometryProxy))
                                        .offset(y: calculateOffset(geometryProxy))
                                }
                                .zIndex(-zIndex(item))
                                .id(item.id)
                                .onChange(of: itemProxy.frame(in: .scrollView).minY) { oldValue, newValue in
                                    // Отслеживаем только разделители
                                    if item.date == nil {
                                        let isOldVisible = oldValue >= 0 && oldValue <= UIScreen.main.bounds.height
                                        let isNewVisible = newValue >= 0 && newValue <= UIScreen.main.bounds.height
                                        
                                        // Когда разделитель исчезает
                                        if isOldVisible && !isNewVisible {
                                            // Если скролл вверх
                                            if newValue < 0 {
                                                if let nextDate = getNextDate(for: item, in: items) {
                                                    onMonthChanged(nextDate)
                                                }
                                            }
                                            // Если скролл вниз
                                            else if let prevDate = getPreviousDate(for: item, in: items) {
                                                onMonthChanged(prevDate)
                                            }
                                        }
                                    }
                                }
                        }
                        .frame(height: itemHeight)
                    }
                }
                .padding(.top, itemHeight * CGFloat(stackedDisplayCount))
            }
            .onAppear {
                if let currentIndex = items.firstIndex(where: {
                    guard let date = $0.date else { return false }
                    return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day)
                }) {
                    scrollProxy.scrollTo(items[currentIndex].id, anchor: .top)
                }
            }
        }
    }
    
    private nonisolated func calculateOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 0 }
        
        return min(-minY, itemHeight * CGFloat(stackedDisplayCount))
    }
    
    private nonisolated func calculateScale(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 1 }
        
        let progress = min(-minY / itemHeight, CGFloat(stackedDisplayCount))
        return 1 - (progress * 0.08)
    }
    
    private nonisolated func calculateOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 1 }
        
        let progress = min(-minY / itemHeight, CGFloat(opacityDisplayCount))
        return 1 - (progress * 0.3)
    }
    
    private func getNextDate(for item: DayItem, in items: [DayItem]) -> Date? {
        if let index = items.firstIndex(where: { $0.id == item.id }),
           index < items.count - 1,
           let date = items[index + 1].date {
            return date
        }
        return nil
    }
    
    private func getPreviousDate(for item: DayItem, in items: [DayItem]) -> Date? {
        if let index = items.firstIndex(where: { $0.id == item.id }),
           index > 0,
           let date = items[index - 1].date {
            return date
        }
        return nil
    }
    
    private func zIndex(_ item: DayItem) -> Double {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            return Double(items.count - index)
        }
        return 0
    }
}
