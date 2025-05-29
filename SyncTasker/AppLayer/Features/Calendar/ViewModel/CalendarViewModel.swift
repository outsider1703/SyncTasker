//
//  CalendarViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import Foundation
import CoreData

class CalendarViewModel: NSObject, ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    private let fetchController: NSFetchedResultsController<TaskEntity>
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    
    // MARK: - Published Properties
    
    @Published var tasks: [TaskItem] = []
    @Published var monthsInYear: [MonthItem] = []
    @Published var weeksInYear: [WeekItem] = []
    @Published var weekIndex: Int = 0
    @Published var isBacklogOpen: Bool = false
    @Published var errorMessage: String?
    @Published var calendarViewType: CalendarViewType = .month
    @Published var selectedFilter: TaskFilterOption = .all
    
    // MARK: - Computed Properties
    
    var statistics: TaskStatistics { TaskStatistics(tasks: tasks) }
    var taskSections: [TaskGroupSection] {
        let filtered = backlogTasks.filter { selectedFilter.filter($0) }
        return TaskGroupSection.group(filtered)
    }
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private var dailyTasks: [Date?: [TaskItem]] = [:]
    private var backlogTasks: [TaskItem] = []
    
    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        feedbackManager: FeedbackManager
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        self.feedbackManager = feedbackManager
        
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: true)]
        
        self.fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataService.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        self.fetchController.delegate = self
        self.loadTasks()
        self.setupWeekIndex(for: monthsInYear.first(where: { $0.isCurrentMonth }))
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTaskDetail(_ task: TaskItem? = nil) {
        Task { await navigationService.navigate(to: .taskDetail(task)) }
    }
    
    func navigateToDaily(_ dayitem: DayItem) {
        Task { await navigationService.navigate(to: .daily(dayitem)) }
    }
    
    func navigateToFreeTime() {
        Task { await navigationService.navigate(to: .freeTime(monthsInYear)) }
    }
    
    // MARK: - Public Methods
    
    func updateTaskDate(task: UUID, to date: Date?) {
        update(for: task, and: date)
    }
    
    func deleteTask(_ task: TaskItem) {
        do {
            try coreDataService.delete(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func didTapYearLabel() {
        calendarViewType = .year
    }
    
    func didTapMonth(with month: MonthItem) {
        calendarViewType = .month
        setupWeekIndex(for: month)
    }
    
    // MARK: - Private Methods
    
    private func loadTasks() {
        do {
            try fetchController.performFetch()
            tasks = (fetchController.fetchedObjects ?? []).map { $0.toTask() }
            let groupedTasks = tasks.groupByDailyTasks()
            dailyTasks = groupedTasks.dailyTasks
            backlogTasks = groupedTasks.backlogTasks
            
            setupCalendarData(for: Date(), using: SleepInstruction(
                weekdayPeriod: SleepPeriod(startHour: 6, startMinute: 30, endHour: 21, endMinute: 00) ,
                weekendPeriod: SleepPeriod(startHour: 10, startMinute: 00, endHour: 23, endMinute: 30) ,
                specialDates: [Date().toKey() : SleepPeriod(startHour: 12, startMinute: 00, endHour: 19, endMinute: 00) ])
            )
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupCalendarData(for dateInYear: Date, using sleepInstruction: SleepInstruction) {
        guard let yearInterval = calendar.dateInterval(of: .year, for: dateInYear) else { return }
        
        // создаём весь год как последовательность Date
        let allDates = calendar.dates(from: yearInterval.start, through: yearInterval.end, adding: .day, value: 1)
        
        // для каждой даты добавляем утренний/вечерний сон
        var combinedTasks = dailyTasks
        for day in allDates {
            let period = sleepInstruction.getPeriod(by: day.toKey())
            let morning = TaskItem(title: "sleep", startDate: day.at(0, 0), endDate: day.at(period.startHour, period.startMinute))
            let evening = TaskItem(title: "sleep", startDate: day.at(period.endHour, period.endMinute), endDate: day.at(23, 59))
            combinedTasks[day.toKey(), default: []].append(contentsOf: [morning, evening])
        }
        dailyTasks = combinedTasks
        
        // собираем месяцы
        monthsInYear = allDates
            .chunkedByMonth(calendar: calendar)
            .map { month in
                let monthPadded = month.padded(toMultipleOf: 7, calendar: calendar)
                let items = monthPadded.map { DayItem(id: UUID(), date: $0, tasks: dailyTasks[$0?.toKey()] ?? []) }
                return MonthItem(id: UUID(), dayItems: items)
            }
        
        // собираем недели
        weeksInYear = allDates
            .padded(toMultipleOf: 7, calendar: calendar)
            .chunked(into: 7)
            .map { weekDates in
                let items = weekDates.map {
                    return DayItem(id: UUID(), date: $0, tasks: dailyTasks[$0?.toKey()] ?? [])
                }
                return WeekItem(id: UUID(), dayItems: items)
            }
    }
    
    private func update(for taskId: UUID, and date: Date?) {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        let updatedTask = TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            startDate: date,
            endDate: date?.addingTimeInterval(3600),
            isCompleted: task.isCompleted,
            priority: task.priority,
            createdAt: task.createdAt,
            updatedAt: Date(),
            isAllDay: task.isAllDay,
            travelTime: task.travelTime
        )
        
        do {
            try coreDataService.updateTask(updatedTask)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupWeekIndex(for month: MonthItem?) {
        guard let month else { return }
        weekIndex = weeksInYear.firstIndex(where: { weekItem in
            weekItem.dayItems.contains(where: { dayItem in
                guard let date = dayItem.date else { return false }
                let isCurrentMonth = calendar.isDate(month.dayItems.firstDate, equalTo: Date(), toGranularity: .month)
                return isCurrentMonth ? calendar.isDateInToday(date) : date == month.dayItems.firstDate
            })
        }) ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CalendarViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadTasks()
    }
}

// MARK: — Структуры для сна

/// Период сна (часы и минуты начала/конца)
struct SleepPeriod {
    let startHour: Int, startMinute: Int
    let endHour:   Int, endMinute:   Int
}

/// Инструкция:
///  • weekdayPeriod  — для будних
///  • weekendPeriod  — для выходных
///  • specialDates   — для конкретных дат (день → период)
struct SleepInstruction {
    let weekdayPeriod: SleepPeriod
    let weekendPeriod: SleepPeriod
    let specialDates:  [Date: SleepPeriod]
    
    func getPeriod(by date: Date) -> SleepPeriod {
        if let special = specialDates[date] {
            return special
        } else if Calendar.current.isDateInWeekend(date) {
            return weekendPeriod
        } else {
            return weekdayPeriod
        }
    }
}
