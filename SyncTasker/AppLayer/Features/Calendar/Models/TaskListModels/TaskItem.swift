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
    var dueDate: Date?
    var isCompleted: Bool
    var priority: Priority
    var createdAt: Date
    var updatedAt: Date
    var appointmentDate: Date?
    
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
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        appointmentDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.appointmentDate = appointmentDate
    }
}
