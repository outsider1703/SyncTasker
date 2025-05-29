//
//  SleepInstruction.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation

/// Инструкция:
///  • weekdayPeriod  — для будних
///  • weekendPeriod  — для выходных
///  • specialDates   — для конкретных дат (день → период)
struct SleepInstruction: Identifiable {
    
    let id: UUID
    let weekdayPeriod: SleepPeriod
    let weekendPeriod: SleepPeriod
    let specialDates:  [Date: SleepPeriod]
    
    init(
        id: UUID,
        weekdayPeriod: SleepPeriod,
        weekendPeriod: SleepPeriod,
        specialDates: [Date : SleepPeriod]
    ) {
        self.id = id
        self.weekdayPeriod = weekdayPeriod
        self.weekendPeriod = weekendPeriod
        self.specialDates = specialDates
    }
    
    func getPeriod(by date: Date) -> SleepPeriod {
        if let special = specialDates[date] {
            return special
        } else if Calendar.current.isDateInWeekend(date) {
            return weekendPeriod
        } else {
            return weekdayPeriod
        }
    }
}
