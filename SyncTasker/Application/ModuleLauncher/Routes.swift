//
//  Routes.swift
//  SyncTasker
//
//  Created by ingvar on 14.02.2025.
//

//NavigationStack в SwiftUI требует:
//- path: Состояние, отслеживающее текущий путь навигации
//- Начальное представление (root view)
//- Правила для создания других представлений при навигации

import Foundation

enum Route: Hashable, Identifiable {
    case calendar
    case taskDetail(TaskItem?)
    case daily(DayItem)
    case freeTime([MonthItem])
    case sleepInstructaions
    
    var id: String {
        switch self {
        case .calendar: return "calendar"
        case .taskDetail(_): return "taskDetail"
        case .daily(_): return "daily"
        case .freeTime(_): return "freeTime"
        case .sleepInstructaions: return "sleepInstructaions"
        }
    }
    
    var isModal: Bool {
        switch self {
        case .calendar, .daily, .freeTime: return false
        case .taskDetail, .sleepInstructaions: return true
        }
    }
}
