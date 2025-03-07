//
//  TravelTime.swift
//  SyncTasker
//
//  Created by ingvar on 07.03.2025.
//

import Foundation

enum TravelTime: Int, CaseIterable, Identifiable {
    case none = 0
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case oneHourThirty = 90
    case twoHours = 120
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .none:
            return "Нет"
        case .fiveMinutes:
            return "5 минут"
        case .fifteenMinutes:
            return "15 минут"
        case .thirtyMinutes:
            return "30 минут"
        case .oneHour:
            return "1 час"
        case .oneHourThirty:
            return "1 час 30 минут"
        case .twoHours:
            return "2 часа"
        }
    }
    
    var minutes: Int {
        return rawValue
    }
}
