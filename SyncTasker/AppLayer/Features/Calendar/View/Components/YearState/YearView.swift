//
//  YearView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct YearView: View {
    
    // MARK: - Initial Private Properties
    
    @State private var year: [MonthItem]
    private let statistics: TaskStatistics
    private let onMonthSelected: (MonthItem) -> Void
    
    // MARK: - Private Properties
    
    private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    // MARK: - Initialization
    
    init(
        year: [MonthItem],
        statistics: TaskStatistics,
        onMonthSelected: @escaping (MonthItem) -> Void
    ) {
        self.year = year
        self.statistics = statistics
        self.onMonthSelected = onMonthSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LazyVGrid(columns: monthColumns, spacing: 0) {
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

#if DEBUG
struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
