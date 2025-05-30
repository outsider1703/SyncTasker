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
    private(set) var sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol

    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol = CoreDataService.shared,
        feedbackManager: FeedbackManager = FeedbackManager.shared,
        sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol = SleepInstructionUpdateService(),
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
        self.sleepInstructionUpdateService = sleepInstructionUpdateService
    }
    
    //MARK: - Factory Methods
    
    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            coreDataService: coreDataService,
            navigationService: navigationService,
            feedbackManager: feedbackManager,
            sleepInstructionUpdateService: sleepInstructionUpdateService
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
            coreDataService: coreDataService,
            sleepInstructionUpdateService: sleepInstructionUpdateService
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
