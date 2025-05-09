//
//  DailyScheduleViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import Foundation

class DailyScheduleViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    private let date: Date?
    private let tasks: [TaskItem]
    
    // MARK: - Properties
    
    @Published var dailyTasks: [CGFloat: [DailyTask]] = [:]
    @Published var navigationTitle: String
    
    // MARK: - Initialization
    
    init(
        navigationService: NavigationServiceProtocol,
        feedbackManager: FeedbackManager,
        dayItem: DayItem
    ) {
        self.navigationService = navigationService
        self.feedbackManager = feedbackManager
        self.date = dayItem.date
        self.tasks = dayItem.tasks ?? []
        
        navigationTitle = dayItem.date?.toString() ?? ""
        organizeTasksByHour()
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTaskDetail(_ task: TaskItem?) {
        Task { await navigationService.navigate(to: .taskDetail(task)) }
    }

    // MARK: - Private Methods
    
    private func organizeTasksByHour() {
        let taskFrameModel = tasks.map { task in
            if let startDate = task.startDate, let endDate = task.endDate {
                let startHour = startDate.inHours(for: 60)
                let endHour = endDate.inHours(for: 60)
                
                let startTime = startHour + startDate.inMinuts()
                let duration = (endHour + endDate.inMinuts()) - (startHour + startDate.inMinuts())
                
                return DailyTask(task: task, offset: CGFloat(startTime), height: CGFloat(duration))
            }
            return DailyTask(task: task, offset: 0, height: 0)
        }
        dailyTasks = Dictionary(grouping: taskFrameModel) { $0.offset }
    }
}
