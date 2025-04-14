//
//  MonthGridItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthGridItem: View {
    
    // MARK: - Private Properties
    
    private let month: [DayItem]
    private let onMonthSelected: ([DayItem]) -> Void
    
    // MARK: - Computed Properties
    
    private var monthTitle: String {
        let firstDay = month.first?.date ?? Date()
        return firstDay.toString(format: "MMMM")
    }
    
    // MARK: - Initialization
    
    init(
        month: [DayItem],
        onMonthSelected: @escaping ([DayItem]) -> Void
    ) {
        self.month = month
        self.onMonthSelected = onMonthSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: { onMonthSelected(month) }) {
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
        .buttonStyle(PlainButtonStyle())
    }
}
