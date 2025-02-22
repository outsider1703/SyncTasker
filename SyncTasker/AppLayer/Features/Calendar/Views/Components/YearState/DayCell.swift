//
//  DayCell.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayCell: View {
    
    let dayItem: DayItem
    let selectedDate: Date
    let calendar: Calendar
    
    var body: some View {
        if let date = dayItem.date {
            let isCurrentDate = calendar.isDate(date, inSameDayAs: selectedDate)
            RoundedRectangle(cornerRadius: 1)
                .frame(width: 16, height: 16)
                .background(isCurrentDate ? Theme.Colors.primary.opacity(0.2) : Color.clear)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 16, height: 16)
        }
    }
}
