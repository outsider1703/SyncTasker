//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Initial Private Properties
    
    @State private var months: [DayItem] = []
    @Binding private var currentMonth: Date
    private let onTaskDropped: (UUID, Date?) -> Void
    private let routeToDailySchedule: (DayItem) -> Void
    
    // MARK: - Initialization
    
    init(
        month: [DayItem],
        currentMonth: Binding<Date>,
        onTaskDropped: @escaping (UUID, Date?) -> Void,
        routeToDailySchedule: @escaping (DayItem) -> Void
    ) {
        self.months = month
        self._currentMonth = currentMonth
        self.onTaskDropped = onTaskDropped
        self.routeToDailySchedule = routeToDailySchedule
    }
    
    // MARK: - Body
    
    var body: some View {
        StackedCards(items: months, currentMonth: $currentMonth, itemHeight: 150) { dayItem in
            DayView(dayItem: dayItem, onTaskDropped: onTaskDropped)
                .onTapGesture { routeToDailySchedule(dayItem) }
        }
    }
}
