//
//  TaskItem.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation
import SwiftUI

struct TaskItem: Identifiable, Hashable {
    
    let id: UUID
    var title: String
    var description: String?
    var endDate: Date?
    var isCompleted: Bool
    var priority: Priority
    var repetition: Repetition
    var reminder: Reminder
    var createdAt: Date
    var updatedAt: Date
    var startDate: Date?
    var travelTime: Date?
    var isAllDay: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        endDate: Date? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        repetition: Repetition = .none,
        reminder: Reminder = .none,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        startDate: Date? = nil,
        isAllDay: Bool = false,
        travelTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.repetition = repetition
        self.reminder = reminder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.startDate = startDate
        self.isAllDay = isAllDay
        self.travelTime = travelTime
    }
}

extension TaskItem {
    
    enum Priority: Int, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var title: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return Theme.Colors.priorityLow
            case .medium: return Theme.Colors.priorityMedium
            case .high: return Theme.Colors.priorityHigh
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "gauge.with.dots.needle.33percent"
            case .medium: return "gauge.with.dots.needle.50percent"
            case .high: return "gauge.with.dots.needle.67percent"
            }
        }
    }
    
    enum Repetition: String, CaseIterable {
        case none = "Никогда"
        case everyDay = "Каждый день"
        case everyWeek = "Каждую неделю"
        case everyTwoWeek = "Каждые две недели"
        case everyMothe = "Каждый месяц"
        case everyYear = "Каждый год"
    }
    
    enum Reminder: String, CaseIterable {
        case none = "Нет"
        case inTime = "В момент события"
        case five = "За 5 минут"
        case ten = "За 10 минут"
        case fifteen = "За 15 минут"
        case thirty = "За 30 минут"
        case hour = "За 1 час"
        case twoHours = "За 2 часа"
        case day = "За 1 день"
        case twoDays = "За 2 дня"
        case week = "За 1 неделю"
    }
}
