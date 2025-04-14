//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Private Properties
    
    @State private var months: [DayItem] = []
    
    @Binding private var currentMonth: Date
    @Binding private var selectedDate: Date
    @State private var visibleMonth: Date?
    private let onTaskDropped: (UUID, Date) -> Void
    private let routeToDailySchedule: (Date, [TaskItem]) -> Void
    
    // MARK: - Initialization
    
    init(
        month: [DayItem],
        selectedDate: Binding<Date>,
        currentMonth: Binding<Date>,
        onTaskDropped: @escaping (UUID, Date) -> Void,
        routeToDailySchedule: @escaping (Date, [TaskItem]) -> Void
    ) {
        self.months = month
        
        self._selectedDate = selectedDate
        self._currentMonth = currentMonth
        self.onTaskDropped = onTaskDropped
        self.routeToDailySchedule = routeToDailySchedule
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            if !months.isEmpty {
                StackedCards(
                    items: months,
                    selectedDate: selectedDate,
                    itemHeight: 150,
                    onMonthChanged: { updateMonthTitle(for: $0) }
                ) { dayItem in
                    if let date = dayItem.date {
                        DayView(
                            dayItem: dayItem,
                            onTap: { routeToDailySchedule(date, dayItem.tasks ?? []) },
                            onTaskDropped: onTaskDropped
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func monthSeparatorView(date: Date) -> some View {
        return Text(date.toString(format: "MMMM yyyy"))
            .font(Theme.Typography.headlineFont)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 150)
            .background(Color.clear)
    }
    
    // MARK: - Private Methods
    
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
