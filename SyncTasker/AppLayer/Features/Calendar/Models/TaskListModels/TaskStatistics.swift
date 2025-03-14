//
//  TaskStatistics.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import Foundation

struct TaskStatistics {
    let total: Int
    let completed: Int
    let overdue: Int
    let highPriority: Int
    
    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    init(tasks: [TaskItem]) {
        self.total = tasks.count
        self.completed = tasks.filter { $0.isCompleted }.count
        self.overdue = tasks.filter {
            guard let endDate = $0.endDate else { return false }
            return !$0.isCompleted && endDate < Date()
        }.count
        self.highPriority = tasks.filter { $0.priority == .high }.count
    }
}

struct TaskGroupSection: Identifiable {
    let id = UUID()
    let title: String
    let tasks: [TaskItem]
    
    static func group(_ tasks: [TaskItem]) -> [TaskGroupSection] {
        let grouped = Dictionary(grouping: tasks) { $0.priority }
        return grouped.map { TaskGroupSection(title: $0.key.title, tasks: $0.value) }
            .sorted { $0.tasks.first?.priority.rawValue ?? 0 > $1.tasks.first?.priority.rawValue ?? 0 }
    }
}
