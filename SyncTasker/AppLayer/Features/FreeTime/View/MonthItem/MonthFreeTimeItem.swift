//
//  MonthFreeTimeItem.swift
//  SyncTasker
//
//  Created by ingvar on 06.05.2025.
//

import SwiftUI

struct MonthFreeTimeItem: View {
    
    // MARK: - Initial Private Properties
    
    private let days: [DayItem]
    private let monthTitle: String
    private let routeToDailySchedule: (DayItem) -> Void

    // MARK: - Private Properties
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        
    // MARK: - Initialization
    
    init(
        month: MonthItem,
        routeToDailySchedule: @escaping (DayItem) -> Void
    ) {
        self.days = month.dayItems
        self.monthTitle = month.title
        self.routeToDailySchedule = routeToDailySchedule
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days, id: \.self) { dayItem in
                    DayFreeTimeCell(dayItem: dayItem)
                        .onTapGesture { routeToDailySchedule(dayItem) }
                }
            }
        }
    }
}

#if DEBUG
struct MonthFreeTimeItem_Previews: PreviewProvider {
    static var previews: some View {
        let initialRouteForFreeTime = Route.freeTime([])
        let previewContainer = DIContainer(initialRoute: initialRouteForFreeTime)
        RootView(container: previewContainer)
    }
}
#endif
