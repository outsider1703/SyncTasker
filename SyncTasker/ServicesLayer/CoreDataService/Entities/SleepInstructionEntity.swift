//
//  SleepInstructionEntity.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation
import CoreData

extension SleepInstructionEntity {
    
    func toSleepInstruction() throws -> SleepInstruction {
        let decoder = JSONDecoder()
        var specialDatesDomain: [Date: SleepPeriod] = [:]
        
        if let specialDatesData = self.specialDatesData {
            let specialDatesStringKey = try decoder.decode([String: SleepPeriod].self, from: specialDatesData)
            for (key, value) in specialDatesStringKey {
                if let timeInterval = TimeInterval(key) {
                    specialDatesDomain[Date(timeIntervalSinceReferenceDate: timeInterval)] = value
                }
            }
        }
        
        let weekdayPeriod = SleepPeriod(
            startSleepTeme: Int(self.weekdayStartSleepTime),
            endSleepTime: Int(self.weekdayEndSleepTime)
        )
        let weekendPeriod = SleepPeriod(
            startSleepTeme: Int(self.weekendStartSleepTime),
            endSleepTime: Int(self.weekendEndSleepTime)
        )
        
        return SleepInstruction(
            id: self.id ?? UUID(),
            weekdayPeriod: weekdayPeriod,
            weekendPeriod: weekendPeriod,
            specialDates: specialDatesDomain
        )
    }
    
    func update(from record: SleepInstruction) throws {
        self.id = record.id
        
        self.weekdayStartSleepTime = Int32(record.weekdayPeriod.startSleepTeme)
        self.weekdayEndSleepTime = Int32(record.weekdayPeriod.endSleepTime)
        self.weekendStartSleepTime = Int32(record.weekendPeriod.startSleepTeme)
        self.weekendEndSleepTime = Int32(record.weekendPeriod.endSleepTime)
        
        let encoder = JSONEncoder()
        var specialDatesStringKey: [String: SleepPeriod] = [:]
        for (date, period) in record.specialDates {
            specialDatesStringKey[date.timeIntervalSinceReferenceDate.description] = period
        }
        self.specialDatesData = try encoder.encode(specialDatesStringKey)
    }
}
