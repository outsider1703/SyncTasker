//
//  MonthGridItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthGridItem: View {
    
    // MARK: - Initial Private Properties

    private let days: [DayItem]
    private let monthTitle: String
        
    // MARK: - Initialization
    
    init(
        month: MonthItem
    ) {
        self.days = month.dayItems
        self.monthTitle = month.title
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<6) { week in
                    HStack(spacing: 2) {
                        ForEach(0..<7) { day in
                            let index = week * 7 + day
                            if index < days.count {
                                DayCell(dayItem: days[index])
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}
