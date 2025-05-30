//
//  SleepInstructionsViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation
import Combine

class SleepInstructionsViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    private let sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol

    // MARK: - Published Properties
    
    @Published var weekdayStartSleepTime: Int = 0
    @Published var weekdayEndSleepTime: Int = 0
    @Published var weekendStartSleepTime: Int = 0
    @Published var weekendEndSleepTime: Int = 0
    @Published var specialDates:  [Date: SleepPeriod] = [:]
    
    // MARK: - Computed Properties
    
    private var userId: UUID {
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        return UUID(uuidString: userId) ?? UUID()
    }
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol
    ) {
        self.coreDataService = coreDataService
        self.sleepInstructionUpdateService = sleepInstructionUpdateService

        Task {
            let sleepInstructions = try await coreDataService.fetchSleepInstructions()
            guard let userSleepInstructions = sleepInstructions?.first(where: { $0.id == userId }) else { return }
            weekdayStartSleepTime = userSleepInstructions.weekdayPeriod.startSleepTeme
            weekdayEndSleepTime = userSleepInstructions.weekdayPeriod.endSleepTime
            weekendStartSleepTime = userSleepInstructions.weekendPeriod.startSleepTeme
            weekendEndSleepTime = userSleepInstructions.weekendPeriod.endSleepTime
            specialDates = userSleepInstructions.specialDates
        }
    }
    
    // MARK: - Public Methods
    
    func saveNewSleepInstructions() {
        Task {
            let sleepInstruction = SleepInstruction(
                id: userId,
                weekdayPeriod: SleepPeriod(startSleepTeme: weekdayStartSleepTime, endSleepTime: weekdayEndSleepTime),
                weekendPeriod: SleepPeriod(startSleepTeme: weekendStartSleepTime, endSleepTime: weekendEndSleepTime),
                specialDates: specialDates
            )
            try await coreDataService.updateSleepInstruction(sleepInstruction)
            sleepInstructionUpdateService.notifyUpdate()
        }
    }
}
