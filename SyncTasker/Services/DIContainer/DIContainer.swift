//
//  DIContainer.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import Foundation

class DIContainer {
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Services
    private(set) var coreDataService: CoreDataServiceProtocol
    
    // MARK: - Initialization
    init(coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
    }
    
    //MARK: - Factory Methods
    func makeTaskListViewModel() -> TaskListViewModel {
        return TaskListViewModel(coreDataService: coreDataService)
    }
    func makeTaskDetailViewModel(task: Task) -> TaskDetailViewModel {
        return TaskDetailViewModel(task: task, coreDataService: coreDataService)
    }
}
