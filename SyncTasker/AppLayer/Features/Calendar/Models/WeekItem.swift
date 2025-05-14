//
//  WeekItem.swift
//  SyncTasker
//
//  Created by ingvar on 14.05.2025.
//

import Foundation

struct WeekItem: Identifiable, Hashable {
    
    // MARK: - Properties

    /// Id месяца
    let id: UUID
    /// Массив дней в месяце
    let dayItems: [DayItem]
    
    // MARK: - Computed Properties

    var title: String {
        let firstDay = dayItems.first(where: { $0.date != nil })?.date
        return firstDay?.toString(format: "MMMM") ?? ""
    }

    var isCurrentMonth: Bool {
        dayItems.compactMap({ $0.date?.isToday() }).contains(true)
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID,
        dayItems: [DayItem]
    ) {
        self.id = id
        self.dayItems = dayItems
    }
}
