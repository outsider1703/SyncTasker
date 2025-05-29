//
//  SleepPeriod.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation

/// Период сна (часы и минуты начала/конца)
struct SleepPeriod: Codable {
    let startHour: Int, startMinute: Int
    let endHour:   Int, endMinute:   Int
}

