//
//  DailyViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import Foundation

class DailyViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    private let dayItem: DayItem
    
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
        self.dayItem = dayItem
        
        navigationTitle = dayItem.date?.toString() ?? ""
        organizeTasksByHour()
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTaskDetail(_ task: TaskItem?) {
        Task { await navigationService.navigate(to: .taskDetail(task)) }
    }
    
    // MARK: - Private Methods
    
    private func organizeTasksByHour() {        
        let taskFrameModel = dayItem.tasks.map { task in
            guard let startDate = task.startDate, let endDate = task.endDate else {
                return DailyTask(task: task, offset: 0, height: 0)
            }
            
            let startTime = startDate.inHours(for: 60) + startDate.inMinuts()
            let endTime = endDate.inHours(for: 60) + endDate.inMinuts()
            let duration = endTime - startTime
            
            return DailyTask(task: task, offset: CGFloat(startTime), height: CGFloat(duration))
        }

        dailyTasks = Dictionary(grouping: taskFrameModel) { $0.offset }
    }
}
