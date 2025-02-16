//
//  TaskFilterOption.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import Foundation

enum TaskFilterOption: Int, CaseIterable {
    case all
    case active
    case completed
    
    var title: String {
        switch self {
        case .all: return "All Tasks"
        case .active: return "Active"
        case .completed: return "Completed"
        }
    }
    
    func filter(_ task: TaskItem) -> Bool {
        switch self {
        case .all: return true
        case .active: return !task.isCompleted
        case .completed: return task.isCompleted
        }
    }
}
