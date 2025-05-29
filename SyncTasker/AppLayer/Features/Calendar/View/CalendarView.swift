//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Initialization
    
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            switch viewModel.calendarViewType {
            case .month:
                WeekView(
                    weekIndex: $viewModel.weekIndex,
                    isBacklogOpen: $viewModel.isBacklogOpen,
                    calendarViewType: $viewModel.calendarViewType,
                    weeks: viewModel.weeksInYear,
                    onTaskDropped: { viewModel.updateTaskDate(task: $0, to: $1) },
                    routeToDaily: { viewModel.navigateToDaily($0) },
                    routeToFreeTimes: { viewModel.navigateToFreeTime() },
                    routeToTaskDetails: { viewModel.navigateToTaskDetail() }
                )
                
            case .year:
                YearView(
                    year: viewModel.monthsInYear,
                    statistics: viewModel.statistics,
                    onMonthSelected: { viewModel.didTapMonth(with: $0) }
                )
            }
            
            if viewModel.isBacklogOpen {
                TaskListView(
                    selectedFilter: $viewModel.selectedFilter,
                    errorMessage: $viewModel.errorMessage,
                    taskSections: viewModel.taskSections,
                    navigateToTaskDetail: { viewModel.navigateToTaskDetail($0) },
                    backlogDropped: { viewModel.updateTaskDate(task: $0, to: nil) }
                )
            }
        }
    }
    
    // MARK: - Subviews
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
