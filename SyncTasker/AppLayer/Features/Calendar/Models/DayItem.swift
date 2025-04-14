//
//  DayItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import Foundation

enum DayItemType {
    case day
    case yearSpacing
    case monthSpacing
}

struct DayItem: Identifiable, Hashable {
    
    let id: UUID
    
    let type: DayItemType
    
    let date: Date?
    
    let tasks: [TaskItem]?
}
