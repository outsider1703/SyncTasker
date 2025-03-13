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
    
    @Published var formattedDate: String = ""
    @Published var dayOfWeek: String = ""
    @Published var tasksByHour: [Int: [TaskItem]] = [:]
    @Published var activeHours: [Int] = []
    
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
        setupData()
    }
    
    // MARK: - Private Methods
    
    private func setupData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        formattedDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "EEEE"
        dayOfWeek = dateFormatter.string(from: date)
        
        organizeTasksByHour()
    }
    
    private func organizeTasksByHour() {
        var groupedTasks: [Int: [TaskItem]] = [:]
        let calendar = Calendar.current
        
        for task in tasks {
            guard let startDate = task.startDate else { continue }
            let hour = calendar.component(.hour, from: startDate)
            
            if groupedTasks[hour] == nil {
                groupedTasks[hour] = []
            }
            groupedTasks[hour]?.append(task)
        }
        
        tasksByHour = groupedTasks
        activeHours = Array(groupedTasks.keys).sorted()
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
    
    func markTaskCompleted(_ task: TaskItem) {
        // Implement task completion logic
        feedbackManager.notification(type: .success)
        // Update task in database
    }
}
