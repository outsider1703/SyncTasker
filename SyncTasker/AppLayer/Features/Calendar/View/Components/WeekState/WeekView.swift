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
    private let weeks: [WeekItem]
    private let onTaskDropped: (UUID, Date?) -> Void
    private let routeToDailySchedule: (DayItem) -> Void
    
    // MARK: - Initialization
    
    init(
        weekIndex: Int,
        weeks: [WeekItem],
        onTaskDropped: @escaping (UUID, Date?) -> Void,
        routeToDailySchedule: @escaping (DayItem) -> Void
    ) {
        self.weeks = weeks
        self.onTaskDropped = onTaskDropped
        self.routeToDailySchedule = routeToDailySchedule
        self._weekIndex = State(initialValue: weekIndex)
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $weekIndex) {
            ForEach(weeks.indices, id: \.self) { index in
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
                        GridRow {
                            DayView(dayItem: weeks[index].dayItems[6], onTaskDropped: onTaskDropped) // ВС
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#if DEBUG
struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
