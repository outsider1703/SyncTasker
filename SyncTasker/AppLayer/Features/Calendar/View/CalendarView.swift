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
    
    // MARK: - Computed Properties
    
    private var calendarTitle: String {
        let format = viewModel.calendarViewType == .month ? "MMMM yyyy" : "yyyy"
        return viewModel.currentMonth.toString(format: format)
    }
    
    // MARK: - Initialization
    
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch viewModel.calendarViewType {
                case .month: monthView
                case .year: yearView
                }
            }
            
            floatingButtons
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Subviews
    
    private var monthView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(calendarTitle)
                .font(Theme.Typography.headlineFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture { viewModel.didTapYearLabel() }
                .padding(.leading, 16)
            
            Divider()
                .padding(.vertical, 4)
            
            WeekView(
                currentMonth: $viewModel.currentMonth,
                weeks: viewModel.weeksInYear,
                onTaskDropped: { task, date in
                    viewModel.updateTaskDate(task: task, to: date)
                }, routeToDailySchedule: { dayItem in
                    viewModel.navigateToDailySchedule(dayItem)
                }
            )
            
            Spacer().frame(height: 88)
        }
        
        //            TaskListView(
        //                selectedFilter: $viewModel.selectedFilter,
        //                errorMessage: $viewModel.errorMessage,
        //                taskSections: viewModel.taskSections,
        //                navigateToTaskDetail: { task in
        //                    viewModel.navigateToTaskDetail(task)
        //                },
        //                backlogDropped: { taskId in
        //                    viewModel.updateTaskDate(task: taskId, to: nil)
        //                }
        //            )
    }
    
    private var yearView: some View {
        YearView(year: viewModel.monthsInYear, statistics: viewModel.statistics) { monthItem in
            viewModel.didTapMonth(with: monthItem)
        }
        .frame(maxWidth: .infinity)
    }
        
    private var floatingButtons: some View {
        HStack {
            Button(action: { viewModel.navigateToFreeTime() }) {
                Text("Free Time")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.all, 8)
                    .background(Theme.Colors.accent)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            Spacer()
            Button(action: { viewModel.navigateToTaskDetail(nil) }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Theme.Colors.accent))
                    .shadow(radius: 4)
            }
        }
        .padding([.bottom, .horizontal], 32)
    }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
