//
//  FreeTimeDay.swift
//  SyncTasker
//
//  Created by ingvar on 07.05.2025.
//

import Foundation

struct FreeTimeDay: Identifiable, Hashable {
    
    static func == (lhs: FreeTimeDay, rhs: FreeTimeDay) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Рандомный id
    let id: UUID
    // Тип для объекта ( может быть просто пустота для отступов )
    let type: DayItemType
    // Дата
    let date: Date?
    // Список задач
    let freeTimes: [(start: String, end: String)]?
    
    init(
        id: UUID,
        type: DayItemType,
        date: Date? = nil,
        freeTimes: [(String, String)]? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.freeTimes = freeTimes
    }
}
