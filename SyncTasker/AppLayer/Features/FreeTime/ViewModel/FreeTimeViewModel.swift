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
    private let listDaysInMonth: [DayItem]

    // MARK: - Private Properties
    
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        listDaysInMonth: [DayItem]
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        self.listDaysInMonth = listDaysInMonth
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() async {
        await navigationService.navigateBack()
    }
    
    // MARK: - Public Methods
    
    
    // MARK: - Private Methods

}
