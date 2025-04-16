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
    
    // Рандомный id
    let id: UUID
    // Тип для объекта ( может быть просто пустота для отступов )
    let type: DayItemType
    // Дата
    let date: Date?
    // Список задач
    let tasks: [TaskItem]?
    
    init(id: UUID, type: DayItemType, date: Date? = nil, tasks: [TaskItem]? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.tasks = tasks
    }
}
