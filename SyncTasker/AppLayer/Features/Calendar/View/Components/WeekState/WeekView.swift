//
//  WeekView.swift
//  SyncTasker
//
//  Created by ingvar on 14.05.2025.
//

import SwiftUI

struct WeekView: View {
    
    // MARK: - Initial Private Properties
    
    @Binding private var currentMonth: Date
    private let weeks: [WeekItem]
    private let onTaskDropped: (UUID, Date?) -> Void
    private let routeToDailySchedule: (DayItem) -> Void
    
    // MARK: - Private Properties
    
    @State private var selectedWeekIndex: Int
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    // MARK: - Initialization
    
    init(
        currentMonth: Binding<Date>,
        weeks: [WeekItem],
        onTaskDropped: @escaping (UUID, Date?) -> Void,
        routeToDailySchedule: @escaping (DayItem) -> Void
    ) {
        self._currentMonth = currentMonth
        self.weeks = weeks
        self.onTaskDropped = onTaskDropped
        self.routeToDailySchedule = routeToDailySchedule
        
        let initialIndex: Int
        if let todayIndex = weeks.firstIndex(where: { weekItem in
            weekItem.dayItems.contains(where: { dayItem in
                guard let date = dayItem.date else { return false }
                return Calendar.current.isDateInToday(date)
            })
        }) {
            initialIndex = todayIndex
        } else if !weeks.isEmpty {
            initialIndex = 0
        } else {
            initialIndex = 0
        }
        self._selectedWeekIndex = State(initialValue: initialIndex)
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedWeekIndex) {
            ForEach(weeks.indices, id: \.self) { index in
                VStack {
                    if weeks[index].dayItems.count >= 7 {
                        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                            GridRow {
                                DayView(dayItem: weeks[index].dayItems[0], onTaskDropped: onTaskDropped) // ПН
                                DayView(dayItem: weeks[index].dayItems[1], onTaskDropped: onTaskDropped) // ВТ
                            }
                            GridRow {
                                DayView(dayItem: weeks[index].dayItems[2], onTaskDropped: onTaskDropped) // СР
                                DayView(dayItem: weeks[index].dayItems[3], onTaskDropped: onTaskDropped) // ЧТ
                            }
                            GridRow {
                                DayView(dayItem: weeks[index].dayItems[4], onTaskDropped: onTaskDropped) // ПТ
                                DayView(dayItem: weeks[index].dayItems[5], onTaskDropped: onTaskDropped) // СБ
                            }
                        }
                        HStack {
                            DayView(dayItem: weeks[index].dayItems[6], onTaskDropped: onTaskDropped) // ВС
                                .frame(height: 150)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: selectedWeekIndex) { newIndex in
            if weeks.indices.contains(newIndex) {
                let currentWeekFirstValidDate = weeks[newIndex].dayItems.first(where: { $0.date != nil })?.date
                if let date = currentWeekFirstValidDate {
                    if !Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                        currentMonth = date
                    }
                }
            }
        }
        .onAppear {
            if weeks.indices.contains(selectedWeekIndex) {
                let initialWeekFirstValidDate = weeks[selectedWeekIndex].dayItems.first(where: { $0.date != nil })?.date
                if let date = initialWeekFirstValidDate {
                    currentMonth = date
                }
            }
        }
    }
}

private struct DayViewWrapper: View {
    let dayItem: DayItem
    let onTaskDropped: (UUID, Date?) -> Void
    let routeToDailySchedule: (DayItem) -> Void
    var isSundaySpecial: Bool = false
    
    var body: some View {
        Group {
            if dayItem.date != nil {
                DayView(
                    dayItem: dayItem,
                    onTaskDropped: onTaskDropped
                )
                .onTapGesture {
                    routeToDailySchedule(dayItem)
                }
                .frame(maxWidth: .infinity)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(minHeight: 100)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
