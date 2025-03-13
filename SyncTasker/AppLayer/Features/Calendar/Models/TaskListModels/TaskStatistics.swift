//
//  TaskStatistics.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import Foundation

enum TaskGroupType: Int, CaseIterable {
    case none, dueDate, priority, status
    
    var title: String {
        switch self {
        case .none: return "No Grouping"
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .status: return "Status"
        }
    }
}

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
    
    static func group(_ tasks: [TaskItem], by type: TaskGroupType) -> [TaskGroupSection] {
        switch type {
        case .none:
            return [TaskGroupSection(title: "", tasks: tasks)]
            
        case .dueDate:
            let grouped = Dictionary(grouping: tasks) { task -> String in
                guard let endDate = task.endDate else { return "No Due Date" }
                if endDate < Date() { return "Overdue" }
                if Calendar.current.isDateInToday(endDate) { return "Today" }
                if Calendar.current.isDateInTomorrow(endDate) { return "Tomorrow" }
                return "Upcoming"
            }
            return grouped.map { TaskGroupSection(title: $0.key, tasks: $0.value) }.sorted { $0.title < $1.title }
            
        case .priority:
            let grouped = Dictionary(grouping: tasks) { $0.priority }
            return grouped.map { TaskGroupSection(title: $0.key.title, tasks: $0.value) }.sorted { $0.title > $1.title }
            
        case .status:
            let grouped = Dictionary(grouping: tasks) { $0.isCompleted }
            return grouped.map { TaskGroupSection(title: $0.key ? "Completed" : "Active", tasks: $0.value) }
        }
    }
}

