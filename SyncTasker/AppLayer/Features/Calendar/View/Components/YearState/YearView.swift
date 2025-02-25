//
//  YearView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct YearView: View {
    
    // MARK: - Private Properties
    
    @Binding private var selectedDate: Date
    private let onMonthSelected: (Date) -> Void
    private let calendar = Calendar.current
    private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    // MARK: - Initialization
    
    init(
        selectedDate: Binding<Date>,
        onMonthSelected: @escaping (Date) -> Void
    ) {
        self._selectedDate = selectedDate
        self.onMonthSelected = onMonthSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: monthColumns, spacing: 20) {
                ForEach(getMonthsInYear(), id: \.self) { month in
                    MonthGridItem(month: month,
                                  selectedDate: selectedDate,
                                  calendar: calendar,
                                  onMonthSelected: onMonthSelected)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    
    private var startOfYear: Date {
        let components = calendar.dateComponents([.year], from: selectedDate)
        return calendar.date(from: components) ?? selectedDate
    }
    
    private func getMonthsInYear() -> [Date] {
        let interval = calendar.dateInterval(of: .year, for: startOfYear)!
        var months: [Date] = []
        var date = interval.start
        
        while date < interval.end {
            months.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        
        return months
    }
}
