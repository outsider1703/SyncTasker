//
//  SleepInstructionsViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation

class SleepInstructionsViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    
    // MARK: - Properties
    
    // MARK: - Initialization

    init(
        coreDataService: CoreDataServiceProtocol
    ) {
        self.coreDataService = coreDataService
    }
}
