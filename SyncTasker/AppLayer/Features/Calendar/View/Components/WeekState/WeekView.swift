//
//  WeekView.swift
//  SyncTasker
//
//  Created by ingvar on 14.05.2025.
//

import SwiftUI

struct WeekView: View {
    
    // MARK: - Initial Private Properties
    
    @State private var weekIndex: Int
    @Binding private var isBacklogOpen: Bool
    private let weeks: [WeekItem]
    private let onTaskDropped: (UUID, Date?) -> Void
    private let routeToDailySchedule: (DayItem) -> Void
    private let routeToFreeTimes: () -> Void
    private let routeToTaskDetails: () -> Void
    
    // MARK: - Initialization
    
    init(
        weekIndex: Int,
        isBacklogOpen: Binding<Bool>,
        weeks: [WeekItem],
        onTaskDropped: @escaping (UUID, Date?) -> Void,
        routeToDailySchedule: @escaping (DayItem) -> Void,
        routeToFreeTimes: @escaping () -> Void,
        routeToTaskDetails: @escaping () -> Void
    ) {
        self._weekIndex = State(initialValue: weekIndex)
        self._isBacklogOpen = isBacklogOpen
        self.weeks = weeks
        self.onTaskDropped = onTaskDropped
        self.routeToDailySchedule = routeToDailySchedule
        self.routeToFreeTimes = routeToFreeTimes
        self.routeToTaskDetails = routeToTaskDetails
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $weekIndex) {
            ForEach(weeks.indices, id: \.self) { index in
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    let week = weeks[index]
                    GridRow {
                        DayView(dayItem: week.dayItems[0], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // ПН
                        DayView(dayItem: week.dayItems[1], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // ВТ
                    }
                    GridRow {
                        DayView(dayItem: week.dayItems[2], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // СР
                        DayView(dayItem: week.dayItems[3], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // ЧТ
                    }
                    GridRow {
                        DayView(dayItem: week.dayItems[4], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // ПТ
                        DayView(dayItem: week.dayItems[5], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // СБ
                    }
                    GridRow {
                        DayView(dayItem: week.dayItems[6], onTaskDropped: onTaskDropped, onDayDetail: routeToDailySchedule) // ВС
                        floatingButtons
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - Subviews
            
    private var floatingButtons: some View {
        VStack {
            Button(action: routeToFreeTimes) {
                Text("Free Time")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.all, 4)
                    .background(Theme.Colors.accent)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            HStack {
                Button(action: { isBacklogOpen.toggle() }) {
                    Text("Backlog")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.all, 4)
                        .background(Theme.Colors.accent)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                Button(action: routeToTaskDetails) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Theme.Colors.accent))
                        .shadow(radius: 4)
                }
            }
        }
    }
}

#if DEBUG
struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
