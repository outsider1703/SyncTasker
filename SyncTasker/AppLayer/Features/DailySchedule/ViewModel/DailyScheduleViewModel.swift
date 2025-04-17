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
                let startHour = Calendar.current.component(.hour, from: startDate) * 60
                let startMinute = Calendar.current.component(.minute, from: startDate)
                let endHour = Calendar.current.component(.hour, from: endDate) * 60
                let endMinute = Calendar.current.component(.minute, from: endDate)
                
                let startTime = startHour + startMinute
                let duration = (endHour + endMinute) - (startHour + startMinute)
                
                return DailyTask(task: task, offset: CGFloat(startTime), height: CGFloat(duration))
            }
            return DailyTask(task: task, offset: 0, height: 0)
        }
        dailyTasks = Dictionary(grouping: taskFrameModel) { $0.offset }
    }
}
