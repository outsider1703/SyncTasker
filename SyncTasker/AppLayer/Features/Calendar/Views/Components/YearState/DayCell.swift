//
//  DayCell.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayCell: View {
    
    // MARK: - Private Properties
    
    private let dayItem: DayItem
    private let selectedDate: Date
    private let calendar: Calendar
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem,
        selectedDate: Date,
        calendar: Calendar
    ) {
        self.dayItem = dayItem
        self.selectedDate = selectedDate
        self.calendar = calendar
    }
    
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
