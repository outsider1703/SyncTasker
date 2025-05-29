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
            startHour: Int(self.weekdayStartHour),
            startMinute: Int(self.weekdayStartMinute),
            endHour: Int(self.weekdayEndHour),
            endMinute: Int(self.weekdayEndMinute)
        )
        let weekendPeriod = SleepPeriod(
            startHour: Int(self.weekendStartHour),
            startMinute: Int(self.weekendStartMinute),
            endHour: Int(self.weekendEndHour),
            endMinute: Int(self.weekendEndMinute)
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
        
        self.weekdayStartHour = Int16(record.weekdayPeriod.startHour)
        self.weekdayStartMinute = Int16(record.weekdayPeriod.startMinute)
        self.weekdayEndHour = Int16(record.weekdayPeriod.endHour)
        self.weekdayEndMinute = Int16(record.weekdayPeriod.endMinute)
        
        self.weekendStartHour = Int16(record.weekendPeriod.startHour)
        self.weekendStartMinute = Int16(record.weekendPeriod.startMinute)
        self.weekendEndHour = Int16(record.weekendPeriod.endHour)
        self.weekendEndMinute = Int16(record.weekendPeriod.endMinute)
        
        let encoder = JSONEncoder()
        var specialDatesStringKey: [String: SleepPeriod] = [:]
        for (date, period) in record.specialDates {
            specialDatesStringKey[date.timeIntervalSinceReferenceDate.description] = period
        }
        self.specialDatesData = try encoder.encode(specialDatesStringKey)
    }
}
