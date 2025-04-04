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
    
    // MARK: - Properties
    

    // MARK: - Private Properties
    
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() async {
        await navigationService.navigateBack()
    }
    
    // MARK: - Public Methods
    
    
    // MARK: - Private Methods

}
