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
    private let date: Date
    private let tasks: [TaskItem]
    
    // MARK: - Properties
    
    @Published var allDayTasks: [TaskItem] = []
    @Published var dailyTasks: [CGFloat: [DailyTask]] = [:]
    @Published var navigationTitle: String = ""
    
    // MARK: - Initialization
    
    init(
        navigationService: NavigationServiceProtocol,
        feedbackManager: FeedbackManager,
        date: Date,
        tasks: [TaskItem]
    ) {
        self.navigationService = navigationService
        self.feedbackManager = feedbackManager
        self.date = date
        self.tasks = tasks
        
        navigationTitle = date.toString()
        organizeTasksByHour()
    }
    
    // MARK: - Private Methods
    
    private func organizeTasksByHour() {
        var dayTasks: [TaskItem] = []
        var taskFrameModel: [DailyTask] = []
        
        for task in tasks {
            if task.isAllDay {
                dayTasks.append(task)
            } else if let startDate = task.startDate, let endDate = task.endDate {
                let startHour = Calendar.current.component(.hour, from: startDate) * 60
                let startMinute = Calendar.current.component(.minute, from: startDate)
                let endHour = Calendar.current.component(.hour, from: endDate) * 60
                let endMinute = Calendar.current.component(.minute, from: endDate)
                
                let startTime = startHour + startMinute
                let duration = (endHour + endMinute) - (startHour + startMinute)
                
                taskFrameModel.append(DailyTask(task: task, offset: CGFloat(startTime), height: CGFloat(duration)))
            }
        }
        
        dailyTasks = Dictionary(grouping: taskFrameModel) { $0.offset }
        allDayTasks = dayTasks
    }
}
