//
//  Array+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 23.02.2025.
//

import Foundation

extension Array where Element == DayItem {
    
    var firstDate: Date {
        self.first(where: { $0.date != nil })?.date ?? Date()
    }
}

extension Array where Element == TaskItem {
    
    func groupByAppointmentDate() -> (appointmentTasks: [Date: [TaskItem]], backlogTasks: [TaskItem]) {
        let calendar = Calendar.current
        
        let (withAppointment, withoutAppointment) = self.reduce(into: ([TaskItem](), [TaskItem]())) { result, task in
            if task.startDate != nil {
                result.0.append(task)
            } else {
                result.1.append(task)
            }
        }
        
        let groupedAppointmentTasks = Dictionary(grouping: withAppointment) { task in
            guard let date = task.startDate else { return Date() }
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: components) ?? date
        }
        
        return (appointmentTasks: groupedAppointmentTasks, backlogTasks: withoutAppointment)
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

extension Array {
    
    /// Разбивает по фиксированному размеру
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            let min = Swift.min($0 + size, count)
            return Array(self[$0..<min])
        }
    }
}
