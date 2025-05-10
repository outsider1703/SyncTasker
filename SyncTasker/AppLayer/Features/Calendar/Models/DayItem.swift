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
    
    // MARK: - Properties

    // Рандомный id
    let id: UUID
    // Тип для объекта ( может быть просто пустота для отступов )
    let type: DayItemType
    // Дата
    let date: Date?
    // Список задач
    let tasks: [TaskItem]?
    
    // MARK: - Computed Properties

    // Список начала и конца промежутков свободного времени
    var freeTimes: [(start: String, end: String)]? {
        tasks?.compactMap { task in
            guard let startDate = task.startDate, let endDate = task.endDate else { return nil }
            return (start: startDate.toString(format: "hh:mm"), end: endDate.toString(format: "hh:mm"))
        }
    }
    
    // MARK: - Initialization

    init(
        id: UUID,
        type: DayItemType,
        date: Date? = nil,
        tasks: [TaskItem]? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.tasks = tasks
    }
}
