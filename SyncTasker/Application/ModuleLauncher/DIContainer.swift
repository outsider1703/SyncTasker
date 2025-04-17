//
//  DIContainer.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import Foundation

// DIContainer: создание viewModels

@MainActor
class DIContainer {
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Navigation
    private(set) var navigationService: NavigationService!

    // MARK: - Services
    private(set) var coreDataService: CoreDataServiceProtocol
    private(set) var feedbackManager: FeedbackManager!
    
    // MARK: - Initialization
    init(
        coreDataService: CoreDataServiceProtocol = CoreDataService.shared,
        feedbackManager: FeedbackManager = FeedbackManager.shared
    ) {
        self.navigationService = NavigationService()
        self.coreDataService = coreDataService
        self.feedbackManager = feedbackManager
    }
    
    //MARK: - Factory Methods
    func makeCalendarViewModel() -> CalendarViewModel {
        return CalendarViewModel(
            coreDataService: coreDataService,
            navigationService: navigationService,
            feedbackManager: feedbackManager
        )
    }
    
    func makeTaskDetailViewModel(task: TaskItem?) -> TaskDetailViewModel {
        return TaskDetailViewModel(
            task: task,
            coreDataService: coreDataService,
            navigationService: navigationService
        )
    }
    
    func makeDailyScheduleViewModel(dayItem: DayItem) -> DailyScheduleViewModel {
        return DailyScheduleViewModel(
            navigationService: navigationService,
            feedbackManager: feedbackManager,
            dayItem: dayItem
        )
    }
    
    func makeFreeTimeViewModel(listDaysInMonth: [DayItem]) -> FreeTimeViewModel {
        return FreeTimeViewModel(
            coreDataService: coreDataService,
            navigationService: navigationService,
            listDaysInMonth: listDaysInMonth
        )
    }
}
