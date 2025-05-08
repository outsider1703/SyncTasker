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
    
    @Published var freeTimeDaysInYear: [[FreeTimeDay]] = []
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        daysInYear: [[DayItem]]
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        
        organizeFreeTime(for: daysInYear)
    }
    
    // MARK: - Public Methods
    
    
    // MARK: - Private Methods

    private func organizeFreeTime(for year: [[DayItem]]) {
        freeTimeDaysInYear = year.map({ month in
            month.map { day in
                guard let tasks = day.tasks else {
                    return FreeTimeDay(id: day.id, type: day.type, date: day.date, freeTimes: [])
                }
                
                let extractedTaskTimes: [(start: String, end: String)] = tasks.compactMap { task in
                    guard let startDate = task.startDate, let endDate = task.endDate else { return nil }
                    return (start: startDate.toString(format: "hh:mm"), end: endDate.toString(format: "hh:mm"))
                }
                
                return FreeTimeDay(id: day.id, type: day.type, date: day.date, freeTimes: extractedTaskTimes)
            }
        })
        
    }
}
