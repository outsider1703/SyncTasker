//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private let date: Date
    @Binding private var selectedDate: Date
    
    // MARK: - Initialization
    
    init(
        date: Date,
        selectedDate: Binding<Date>
    ) {
        self.date = date
        self._selectedDate = selectedDate
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(getDaysInMonth()) { dayItem in
                    if let date = dayItem.date {
                        DayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            onTap: { withAnimation { selectedDate = date } }
                        )
                    }
                }
            }
            .padding(.all, 16)
            .padding(.top, 64)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Functions
    
    private func getDaysInMonth() -> [DayItem] {
        let interval = calendar.dateInterval(of: .month, for: date)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days: [DayItem] = []
        for i in 0..<(firstWeekday - 1) {
            days.append(DayItem(id: i, date: nil))
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(DayItem(id: day + firstWeekday - 1, date: date))
            }
        }
        return days
    }
}
