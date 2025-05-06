//
//  FreeTimeViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 04.04.2025.
//

import Foundation

class FreeTimeViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    private let navigationService: NavigationServiceProtocol

    // MARK: - Private Properties
    
    @Published var daysInYear: [[DayItem]]
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        daysInYear: [[DayItem]]
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        self.daysInYear = daysInYear
    }
    
    // MARK: - Navigation Methods
    
    
    // MARK: - Public Methods
    
    
    // MARK: - Private Methods

}
