//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let gradientHeight: CGFloat = 150
    static let floatingButtonSize: CGFloat = 56
    static let addIcon = "plus"
}

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Computed Properties
    
    private var calendarTitle: String {
        let format = viewModel.calendarViewType == .month ? "MMMM yyyy" : "yyyy"
        return viewModel.currentMoutn.toString(format: format)
    }
    
    // MARK: - Initialization
    
    init(
        viewModel: CalendarViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.calendarViewType {
            case .month:
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(calendarTitle)
                            .font(Theme.Typography.headlineFont)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture { viewModel.didTapYearLabel() }
                            .padding(.leading, 16)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        MonthView(
                            month: viewModel.listDaysInMonth,
                            currentMonth: $viewModel.currentMoutn,
                            onTaskDropped: { task, date in
                                viewModel.updateTaskDate(task: task, to: date)
                            }, routeToDailySchedule: { date, tasks in
                                viewModel.navigateToDailySchedule(date, tasks)
                            })
                    }
                    .frame(width: 182)
                    
                    TaskListView(
                        taskSections: viewModel.taskSections,
                        selectedFilter: $viewModel.selectedFilter,
                        errorMessage: $viewModel.errorMessage,
                        navigateToTaskDetail: { task in
                            viewModel.navigateToTaskDetail(task)
                        },
                        backlogDropped: { taskId in
                            viewModel.updateTaskDate(task: taskId, to: nil)
                        }
                    )
                }
                
            case .year:
                YearView(year: viewModel.daysInYear, statistics: viewModel.statistics) { date in
                    viewModel.didTapMonth(with: date)
                }
                .frame(maxWidth: .infinity)
            }
            
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white.opacity(0.8), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Constants.gradientHeight)
            }
            .frame(maxWidth: .infinity)
            
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
                    Image(systemName: Constants.addIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: Constants.floatingButtonSize, height: Constants.floatingButtonSize)
                        .background(Circle().fill(Theme.Colors.accent))
                        .shadow(radius: 4)
                }
            }
            .padding([.bottom, .horizontal], 32)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
