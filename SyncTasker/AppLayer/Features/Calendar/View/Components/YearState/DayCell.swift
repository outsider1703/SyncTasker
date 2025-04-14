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
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem
    ) {
        self.dayItem = dayItem
    }
    
    // MARK: - Body

    var body: some View {
        if let date = dayItem.date {
            let isCurrentDate = Calendar.current.isDate(date, inSameDayAs: Date())
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrentDate ? Theme.Colors.primary.opacity(0.2) : Color.clear)
                .frame(width: 16, height: 16)
                .border(.black)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 16, height: 16)
        }
    }
}

