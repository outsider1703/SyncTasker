//
//  MonthGridItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthGridItem: View {
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private let month: Date
    private let onMonthSelected: (Date) -> Void
    
    // MARK: - Initialization
    
    init(
        month: Date,
        onMonthSelected: @escaping (Date) -> Void
    ) {
        self.month = month
        self.onMonthSelected = onMonthSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            onMonthSelected(month)
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text(month.toString(format: "MMMM"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                let days = generateDaysForMonth(month)
                ForEach(0..<6) { week in
                    HStack(spacing: 2) {
                        ForEach(0..<7) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count {
                                DayCell(dayItem: days[index])
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private func generateDaysForMonth(_ month: Date) -> [DayItem] {
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDayOfMonth = calendar.date(from: components),
              let daysRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
        else { return [] }
        
        let firstWeekday = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7 + 1
        
        var days: [DayItem] = []
        
        for _ in 1..<firstWeekday {
            days.append(DayItem(id: days.count, date: nil))
        }
        
        for day in daysRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DayItem(id: days.count, date: date))
            }
        }
        
        while days.count < 42 {
            days.append(DayItem(id: days.count, date: nil))
        }
        
        return days
    }
}
