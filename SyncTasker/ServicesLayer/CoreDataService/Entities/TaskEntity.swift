//
//  TaskEntity.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import Foundation
import CoreData

extension TaskEntity {
    func toTask() -> TaskItem {
        TaskItem(
            id: id ?? UUID(),
            title: title ?? "",
            description: taskDescription,
            startDate: startDate,
            endDate: endDate,
            isCompleted: isCompleted,
            priority: TaskItem.Priority(rawValue: Int(priority)) ?? .medium,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            isAllDay: isAllDay,
            travelTime: travelTime
        )
    }
    
    func update(from task: TaskItem) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.endDate = task.endDate
        self.isCompleted = task.isCompleted
        self.priority = Int16(task.priority.rawValue)
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
        self.startDate = task.startDate
        self.isAllDay = task.isAllDay
        self.travelTime = task.travelTime
    }
}
