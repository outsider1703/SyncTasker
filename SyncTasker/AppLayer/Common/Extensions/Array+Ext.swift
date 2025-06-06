//
//  Array+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 23.02.2025.
//

import Foundation

extension Array {
    
    /// Разбивает по фиксированному размеру
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            let min = Swift.min($0 + size, count)
            return Array(self[$0..<min])
        }
    }
    
    /// Возвращает два массива: первый — те элементы, для которых predicate вернул true, второй — для которых false.
    func partitioned(by predicate: (Element) -> Bool) -> (matches: [Element], nonMatches: [Element]) {
        return reduce(into: ([Element](), [Element]())) { result, element in
            predicate(element) ? result.0.append(element) : result.1.append(element)
        }
    }
}

extension Array where Element == DayItem {
    
    var firstDate: Date {
        self.first(where: { $0.date != nil })?.date ?? Date()
    }
}

extension Array where Element == TaskItem {
    
    func groupByDailyTasks() -> (dailyTasks: [Date: [TaskItem]], backlogTasks: [TaskItem]) {
        let (withDate, withoutDate) = self.reduce(into: ([TaskItem](), [TaskItem]())) { result, task in
            task.startDate != nil ? result.0.append(task) : result.1.append(task)
        }
        let groupedDailyTasks = Dictionary(grouping: withDate) { $0.startDate!.toKey() }
        
        return (dailyTasks: groupedDailyTasks, backlogTasks: withoutDate)
    }
}

extension Array where Element == Date {
    
    /// Разбивает дату по номеру месяца в данной Calendar
    func chunkedByMonth(calendar: Calendar) -> [[Date]] {
        Dictionary(grouping: self) { calendar.component(.month, from: $0) }
            .sorted(by: { $0.key < $1.key })
            .map { $0.value }
    }
    
    /// Добавляет отступы пустых дней так, чтобы итоговая длина была кратна 7.
    func padded(toMultipleOf targetSize: Int, calendar: Calendar) -> [Date?] {
        var result: [Date?] = []
        // вычисляем leading padding
        if let ref = first {
            let weekday = calendar.component(.weekday, from: ref)
            let leading = (weekday - calendar.firstWeekday + 7) % 7
            for _ in 0..<leading { result.append(nil) }
        }
        // вставляем сами даты
        result += map { Optional($0) }
        // вычисляем trailing padding
        let trailing = (targetSize - (result.count % targetSize)) % targetSize
        for _ in 0..<trailing { result.append(nil) }
        return result
    }
}
