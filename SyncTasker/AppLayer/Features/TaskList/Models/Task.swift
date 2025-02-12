//
//  TaskItem.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation

struct Task: Identifiable {
    let id: UUID
    var title: String?
    var description: String?
    var dueDate: Date?
    var isCompleted: Bool
    var priority: Priority
    var createdAt: Date
    var updatedAt: Date
    
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
        
        var color: String {
            switch self {
            case .low: return "priorityLow"
            case .medium: return "priorityMedium"
            case .high: return "priorityHigh"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String?,
        description: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
