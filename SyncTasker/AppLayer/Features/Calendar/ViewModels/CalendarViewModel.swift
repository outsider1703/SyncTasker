//
//  CalendarViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import Foundation

class CalendarViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationService: NavigationServiceProtocol
    
    // MARK: - Initialization
    init(navigationService: NavigationServiceProtocol) {
        self.navigationService = navigationService
    }
    
    // MARK: - Navigation Methods
    func navigateToTaskList() {
        Task {
            await navigationService.navigate(to: .taskList)
        }
    }
}
