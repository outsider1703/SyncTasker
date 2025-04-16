//
//  MonthGridItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthGridItem: View {
    
    // MARK: - Initial Private Properties

    private let month: [DayItem]
    
    // MARK: - Computed Properties
    
    private var monthTitle: String {
        let firstDay = month.first(where: { $0.type == .day })?.date
        return firstDay?.toString(format: "MMMM") ?? ""
    }
    
    // MARK: - Initialization
    
    init(
        month: [DayItem]
    ) {
        self.month = month
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            ForEach(0..<6) { week in
                HStack(spacing: 2) {
                    ForEach(0..<7) { weekday in
                        let index = week * 7 + weekday
                        if index < month.count {
                            DayCell(dayItem: month[index])
                        }
                    }
                }
            }
        }
    }
}
