//
//  DailyScheduleViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import Foundation

class DailyScheduleViewModel: NSObject, ObservableObject {
    
    // MARK: - Injections
    
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    private let date: Date
    private let tasks: [TaskItem]
    
    // MARK: - Properties
    
    @Published var tasksByHour: [Int: [TaskItem]] = [:]
    @Published var allDayTasks: [TaskItem] = []
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
        
        super.init()
        navigationTitle = date.toString()
        organizeTasksByHour()
    }
    
    // MARK: - Private Methods
        
    private func organizeTasksByHour() {
        var groupedTasks: [Int: [TaskItem]] = [:]
        var dayTasks: [TaskItem] = []

        for task in tasks {
            if task.isAllDay {
                dayTasks.append(task)
                continue
            }
            
            guard let startDate = task.startDate else { continue }
            let hour = Calendar.current.component(.minute, from: startDate)
            
            if groupedTasks[hour] == nil {
                groupedTasks[hour] = []
            }
            groupedTasks[hour]?.append(task)
        }
        
        tasksByHour = groupedTasks
        allDayTasks = dayTasks
    }
    
    // MARK: - Public Methods
    
    func formattedTime(for hour: Int) -> String {
        let is24Hour = UserDefaults.standard.bool(forKey: "use24HourTime")
        
        if is24Hour {
            return String(format: "%02d:00", hour)
        } else {
            let period = hour < 12 ? "AM" : "PM"
            let displayHour = hour % 12 == 0 ? 12 : hour % 12
            return String(format: "%d:00 %@", displayHour, period)
        }
    }
}
