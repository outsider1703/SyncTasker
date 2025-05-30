//
//  SleepPeriod.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import Foundation

/// Период сна (часы и минуты начала/конца)
struct SleepPeriod: Codable {
    let startSleepTeme: Int
    let endSleepTime: Int
}

