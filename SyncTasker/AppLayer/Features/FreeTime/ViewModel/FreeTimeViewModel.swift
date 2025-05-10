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
    
    @Published var months: [MonthItem] = []
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        months: [MonthItem]
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        self.months = months
    }
    
    // MARK: - Public Methods
    
    // MARK: - Navigation Methods
    
    func navigateToDailySchedule(_ dayitem: DayItem) {
        Task { await navigationService.navigate(to: .dailySchedule(dayitem)) }
    }
    
    // MARK: - Private Methods
}
