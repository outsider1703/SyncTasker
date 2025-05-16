//
//  DayItem.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import Foundation

struct DayItem: Identifiable, Hashable {
    
    // MARK: - Properties
    
    // Рандомный id
    let id: UUID
    // Дата
    let date: Date?
    // Список задач
    let tasks: [TaskItem]
    // Время сна
    let sleepTime: ClosedRange<Date>
    
    // MARK: - Computed Properties
    
    // Список начала и конца промежутков свободного времени
    var freeTimes: [(start: String, end: String)]? {
        // 1. Фильтруем задачи: нужны только те, у которых есть startDate и endDate, и startDate < endDate.
        //    Сразу сортируем валидные задачи по времени начала.
        let sortedValidTasks = tasks.compactMap { task -> (start: Date, end: Date)? in
            guard let startDate = task.startDate, let endDate = task.endDate, startDate < endDate else { return nil }
            return (start: startDate, end: endDate)
        }.sorted { $0.start < $1.start }
        
        // 2. Если после фильтрации не осталось валидных задач
        guard !sortedValidTasks.isEmpty else { return nil }
        
        var freeIntervals: [(start: String, end: String)] = []
        // Начальная точка отсчета свободного времени - "00:00"
        var lastProcessedTimeMarker = "00:00"
        
        // 3. Итерируемся по отсортированным задачам
        for taskTime in sortedValidTasks {
            let currentTaskStartTimeString = taskTime.start.toString(format: "HH:mm")
            let currentTaskEndTimeString = taskTime.end.toString(format: "HH:mm")
            
            // Если начало текущей задачи позже, чем конец предыдущего обработанного блока времени,
            // значит, между ними есть свободный промежуток.
            if currentTaskStartTimeString > lastProcessedTimeMarker {
                // Убедимся, что не добавляем интервал нулевой длительности (например, "08:00" - "08:00")
                if lastProcessedTimeMarker != currentTaskStartTimeString {
                    freeIntervals.append((start: lastProcessedTimeMarker, end: currentTaskStartTimeString))
                }
            }
            
            // Обновляем маркер времени до конца текущей задачи, если он позже текущего маркера.
            // Это важно для корректной обработки перекрывающихся или следующих подряд задач.
            if currentTaskEndTimeString > lastProcessedTimeMarker {
                lastProcessedTimeMarker = currentTaskEndTimeString
            }
        }
        
        // 4. Проверяем, есть ли свободное время после последней задачи до конца дня ("23:59")
        let endOfDayMarker = "23:59"
        if lastProcessedTimeMarker < endOfDayMarker {
            // Убедимся, что не добавляем интервал нулевой длительности
            if lastProcessedTimeMarker != endOfDayMarker {
                freeIntervals.append((start: lastProcessedTimeMarker, end: endOfDayMarker))
            }
        }
        
        // Если список свободных интервалов пуст (например, задачи покрыли весь день), возвращаем nil.
        return freeIntervals.isEmpty ? nil : freeIntervals
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID,
        date: Date? = nil,
        tasks: [TaskItem] = [],
        sleepTime: ClosedRange<Date>? = nil
    ) {
        self.id = id
        self.date = date
        self.tasks = tasks
        
        if let providedSleepTime = sleepTime {
            self.sleepTime = providedSleepTime
        } else if let existingDate = date {
            let calendar = Calendar.current
            let startOfSleep = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: existingDate) ?? existingDate
            let endOfSleep = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: existingDate) ?? existingDate
            self.sleepTime = startOfSleep...endOfSleep
        } else {
            self.sleepTime = Date()...Date()
        }
    }
}
