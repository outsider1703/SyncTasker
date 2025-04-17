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
    case dailySchedule(DayItem)
    case freeTime([DayItem])
    
    var id: String {
        switch self {
        case .calendar: return "calendar"
        case .taskDetail(_): return "taskDetail"
        case .dailySchedule(_): return "dailySchedule"
        case .freeTime(_): return "freeTime"
        }
    }
    
    var isModal: Bool {
        switch self {
        case .calendar, .dailySchedule, .freeTime: return false
        case .taskDetail: return true
        }
    }
}
