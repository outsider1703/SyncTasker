//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Private Properties
    
    @State private var days: [DayItem] = []
    @State private var months: [Date] = []
    private let monthsToLoad = 12
    
    private var dailyTasks: [Date: [TaskItem]]
    private let calendar = Calendar.current
    private let selectedDate: Date
    private let onTaskDropped: (UUID, Date) -> Void
    private let routeToDailySchedule: (Date, [TaskItem]) -> Void
    @State private var visibleMonth: Date?
    @Binding var currentMonth: Date
    
    // MARK: - Initialization
    
    init(
        selectedDate: Date,
        currentMonth: Binding<Date>,
        dailyTasks: [Date: [TaskItem]],
        onTaskDropped: @escaping (UUID, Date) -> Void,
        routeToDailySchedule: @escaping (Date, [TaskItem]) -> Void
    ) {
        self.selectedDate = selectedDate
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
                    selectedDate: selectedDate,
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
                        monthSeparatorView(date: nextDate)
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
    private func monthSeparatorView(date: Date) -> some View {        
        return Text(date.toString(format: "MMMM yyyy"))
            .font(Theme.Typography.headlineFont)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 150)
            .background(Color.clear)
    }
    
    // MARK: - Private Methods
    
    private func getTasksForDate(_ date: Date) -> [TaskItem] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let normalizedDate = calendar.date(from: components) else { return [] }
        return dailyTasks[normalizedDate] ?? []
    }
    
    private func generateMonths() {
        months = (-monthsToLoad...monthsToLoad).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: selectedDate)
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
        if let index = items.firstIndex(where: { $0.id == item.id }), index < items.count - 1, let date = items[index + 1].date {
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
