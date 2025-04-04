//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let monthTitleScale: CGFloat = 1.2
    static let titleAnimationDuration: Double = 0.3
    static let gradientHeight: CGFloat = 150
    static let floatingButtonPadding: CGFloat = 16
    static let floatingButtonSize: CGFloat = 56
    static let addIcon = "plus"
}

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Private Properties
    
    @State private var selectedDate = Date()
    @State private var currentMoutn = Date()
    @State private var viewType: CalendarViewType = .month
    @State private var isTitleAnimating = false
    
    // MARK: - Initialization
    
    init(
        viewModel: CalendarViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewType {
            case .month:
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(currentMoutn.toString(format: viewType == .month ? "MMMM yyyy" : "yyyy"))
                            .font(Theme.Typography.headlineFont)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture { switchToYearView() }
                            .padding(.leading, 16)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        MonthView(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMoutn,
                            dailyTasks: viewModel.dailyTasks,
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
                YearView(selectedDate: $selectedDate, statistics: viewModel.statistics, onMonthSelected: switchToMonthView)
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
    
    // MARK: - Private Methods
    
    private func switchToYearView() {
        withAnimation {
            isTitleAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                viewType = .year
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                    isTitleAnimating = false
                }
            }
        }
    }
    
    private func switchToMonthView(with date: Date) {
        withAnimation {
            isTitleAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                currentMoutn = date
                selectedDate = date
                viewType = .month
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                    isTitleAnimating = false
                }
            }
        }
    }
}
