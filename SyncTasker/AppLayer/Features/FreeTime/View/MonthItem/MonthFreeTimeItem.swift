//
//  MonthFreeTimeItem.swift
//  SyncTasker
//
//  Created by ingvar on 06.05.2025.
//

import SwiftUI

struct MonthFreeTimeItem: View {
    
    // MARK: - Initial Private Properties
    
    private let month: [FreeTimeDay]
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 0)
    ]
    
    // MARK: - Computed Properties
    
    private var monthTitle: String {
        let firstDay = month.first(where: { $0.type == .day })?.date
        return firstDay?.toString(format: "MMMM") ?? ""
    }
    
    // MARK: - Initialization
    
    init(
        month: [FreeTimeDay]
    ) {
        self.month = month
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(month, id: \.self) { dayItem in
                    DayFreeTimeCell(dayItem: dayItem)
                }
            }
        }
    }
}

#if DEBUG
struct MonthFreeTimeItem_Previews: PreviewProvider {
    static var previews: some View {
        let initialRouteForFreeTime = Route.freeTime([[]])
        let previewContainer = DIContainer(initialRoute: initialRouteForFreeTime)
        RootView(container: previewContainer)
    }
}
#endif
