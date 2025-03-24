//
//  DailyScheduleViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import Foundation


// MARK: - Constants

private enum Constants {
    static let hourRowHeight: CGFloat = 60
}

class DailyScheduleViewModel: NSObject, ObservableObject {
    
    // MARK: - Injections
    
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    private let date: Date
    private let tasks: [TaskItem]
    
    // MARK: - Properties
    
    @Published var sortedTasks: [TaskItem] = []
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
        var dayTasks: [TaskItem] = []
        var timedTasks: [TaskItem] = []

        for task in tasks {
            if task.isAllDay {
                dayTasks.append(task)
            } else if let startDate = task.startDate {
                timedTasks.append(task)
            }
        }
        
        // Сортируем задачи по времени начала
        sortedTasks = timedTasks.sorted { task1, task2 in
            guard let date1 = task1.startDate, let date2 = task2.startDate else { return false }
            return date1 < date2
        }
        
        allDayTasks = dayTasks
    }
    
    // MARK: - Public Methods
    
    func tasksForHour(_ hour: Int) -> [(task: TaskItem, offset: CGFloat)] {
        var result: [(TaskItem, CGFloat)] = []
        var usedOffsets: Set<Int> = []
        
        for task in sortedTasks {
            guard let startDate = task.startDate, let endDate = task.endDate else { continue }
            
            let taskStartHour = Calendar.current.component(.hour, from: startDate)
            let taskEndHour = Calendar.current.component(.hour, from: endDate)
            
            // Проверяем, пересекается ли задача с текущим часом
            if hour >= taskStartHour && hour <= taskEndHour {
                // Находим свободное смещение для задачи
                var offset = 0
                while usedOffsets.contains(offset) {
                    offset += 1
                }
                usedOffsets.insert(offset)
                
                result.append((task, CGFloat(offset) * 16))
            }
        }
        
        return result
    }
    
    func taskHeight(for task: TaskItem) -> CGFloat {
        guard let startDate = task.startDate, let endDate = task.endDate else { return 0 }
        
        let startHour = Calendar.current.component(.hour, from: startDate)
        let startMinute = Calendar.current.component(.minute, from: startDate)
        let endHour = Calendar.current.component(.hour, from: endDate)
        let endMinute = Calendar.current.component(.minute, from: endDate)
        
        let duration = (endHour - startHour) * 60 + (endMinute - startMinute)
        return CGFloat(duration) * (Constants.hourRowHeight / 60)
    }
    
    func taskTopOffset(for task: TaskItem, in hour: Int) -> CGFloat {
        guard let startDate = task.startDate else { return 0 }
        
        let taskStartHour = Calendar.current.component(.hour, from: startDate)
        let taskStartMinute = Calendar.current.component(.minute, from: startDate)
        
        if taskStartHour == hour {
            return CGFloat(taskStartMinute) * (Constants.hourRowHeight / 60)
        }
        return 0
    }
}
