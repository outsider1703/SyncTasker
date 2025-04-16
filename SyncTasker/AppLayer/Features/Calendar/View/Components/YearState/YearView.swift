//
//  YearView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct YearView: View {
    
    // MARK: - Initial Private Properties
    
    @State private var year: [[DayItem]]
    private let statistics: TaskStatistics
    private let onMonthSelected: ([DayItem]) -> Void
    
    // MARK: - Private Properties
    
    private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    // MARK: - Initialization
    
    init(
        year: [[DayItem]],
        statistics: TaskStatistics,
        onMonthSelected: @escaping ([DayItem]) -> Void
    ) {
        self.year = year
        self.statistics = statistics
        self.onMonthSelected = onMonthSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: monthColumns, spacing: 20) {
                    ForEach(year, id: \.self) { month in
                        MonthGridItem(month: month)
                            .onTapGesture { onMonthSelected(month) }
                    }
                }
                .padding(.horizontal, 16)
                
                TaskStatisticsView(statistics: statistics)
                    .padding(.horizontal, 16)
            }
        }
    }
}
