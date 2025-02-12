//
//  TaskSortOption.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import Foundation

enum TaskSortOption: Int, CaseIterable {
    case createdAt
    case dueDate
    case priority
    case title
    
    var title: String {
        switch self {
        case .createdAt: return "Date Created"
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .title: return "Title"
        }
    }
}
