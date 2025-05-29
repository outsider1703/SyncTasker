//
//  DIContainer.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import Foundation
import SwiftUI

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
        feedbackManager: FeedbackManager = FeedbackManager.shared,
        initialRoute: Route? = nil
    ) {
        var initialNavPath = NavigationPath()
        var initialModalRoute: Route? = nil
        
        if let route = initialRoute {
            route.isModal ? initialModalRoute = route : initialNavPath.append(route)
        }
        
        self.navigationService = NavigationService(initialPath: initialNavPath, initialModal: initialModalRoute)
        self.coreDataService = coreDataService
        self.feedbackManager = feedbackManager
    }
    
    //MARK: - Factory Methods
    
    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            coreDataService: coreDataService,
            navigationService: navigationService,
            feedbackManager: feedbackManager
        )
    }
    
    func makeTaskDetailViewModel(task: TaskItem?) -> TaskDetailViewModel {
        TaskDetailViewModel(
            task: task,
            coreDataService: coreDataService,
            navigationService: navigationService
        )
    }
    
    func makeDailyViewModel(dayItem: DayItem) -> DailyViewModel {
        DailyViewModel(
            navigationService: navigationService,
            feedbackManager: feedbackManager,
            dayItem: dayItem
        )
    }
    
    func makeSleepInstructionsViewModel() -> SleepInstructionsViewModel {
        SleepInstructionsViewModel(
            coreDataService: coreDataService
        )
    }
    
    func makeFreeTimeViewModel(months: [MonthItem]) -> FreeTimeViewModel {
        FreeTimeViewModel(
            coreDataService: coreDataService,
            navigationService: navigationService,
            months: months
        )
    }
}
