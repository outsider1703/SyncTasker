//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    // MARK: - Properties
    
    private let calendar = Calendar.current
    let date: Date
    @Binding var selectedDate: Date
    @State private var viewHeight: CGFloat = 0
    @State private var selectedItemFrame: CGRect = .zero
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(getDaysInMonth()) { dayItem in
                    if let date = dayItem.date {
                        DayView(date: date,
                               isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                               onTap: { withAnimation { selectedDate = date } })
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
