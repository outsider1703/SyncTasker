//
//  TaskEntity.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import Foundation
import CoreData

// MARK: - Task Conversion
extension TaskEntity {
    func toTask() -> Task {
        Task(
            id: id ?? UUID(),
            title: title,
            description: taskDescription,
            dueDate: dueDate,
            isCompleted: isCompleted,
            priority: Task.Priority(rawValue: Int(priority)) ?? .medium,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    func update(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.dueDate = task.dueDate
        self.isCompleted = task.isCompleted
        self.priority = Int16(task.priority.rawValue)
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
    }
}
