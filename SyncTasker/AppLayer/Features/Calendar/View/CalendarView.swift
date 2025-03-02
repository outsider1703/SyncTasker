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
                        Text(monthTitle)
                            .font(Theme.Typography.headlineFont)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .scaleEffect(isTitleAnimating ? Constants.monthTitleScale : 1.0)
                            .opacity(isTitleAnimating ? 0.5 : 1.0)
                            .animation(.easeInOut(duration: Constants.titleAnimationDuration), value: selectedDate)
                            .onTapGesture { switchToYearView() }
                            .padding(.leading, 16)
                        
                        Divider()
                            .padding(.vertical, 4)

                        MonthView(
                            date: selectedDate,
                            selectedDate: $selectedDate,
                            currentMonth: $selectedDate,
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
                        selectedSortOption: $viewModel.selectedSortOption,
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
                Spacer()
                Button(action: { viewModel.navigateToTaskDetail(nil) }) {
                    Image(systemName: Constants.addIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: Constants.floatingButtonSize, height: Constants.floatingButtonSize)
                        .background(Circle().fill(Theme.Colors.accent))
                        .shadow(radius: 4)
                }
                .padding([.bottom, .trailing], 32)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Subviews
    
    private var monthTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = viewType == .month ? "MMMM yyyy" : "yyyy"
        return dateFormatter.string(from: selectedDate)
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
                selectedDate = date
                viewType = .month
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                    isTitleAnimating = false
                }
            }
        }
    }
}
