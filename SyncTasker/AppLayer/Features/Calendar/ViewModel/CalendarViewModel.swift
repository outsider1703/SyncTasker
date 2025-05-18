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
    
    
    @Published var appointmentTasks: [Date: [TaskItem]] = [:]
    @Published var backlogTasks: [TaskItem] = []
    @Published var selectedFilter: TaskFilterOption = .all
    
    // MARK: - Computed Properties
    
    var statistics: TaskStatistics { TaskStatistics(tasks: tasks) }
    var taskSections: [TaskGroupSection] {
        let filtered = backlogTasks.filter { selectedFilter.filter($0) }
        return TaskGroupSection.group(filtered)
    }
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    
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
    
    func navigateToDailySchedule(_ dayitem: DayItem) {
        Task { await navigationService.navigate(to: .dailySchedule(dayitem)) }
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
            let groupedTasks = tasks.groupByAppointmentDate()
            
            appointmentTasks = groupedTasks.appointmentTasks
            backlogTasks = groupedTasks.backlogTasks
            setupCalendarData(for: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupCalendarData(for dateInYear: Date) {
        guard let yearInterval = calendar.dateInterval(of: .year, for: dateInYear) else { return }
        
        // создаём весь год как последовательность Date
        let allDates = calendar.dates(from: yearInterval.start, through: yearInterval.end, adding: .day, value: 1)
        
        // собираем месяцы
        monthsInYear = allDates
            .chunkedByMonth(calendar: calendar)
            .map { month in
                let monthPadded = month.padded(toMultipleOf: 7, calendar: calendar)
                let items = monthPadded.map { DayItem(id: UUID(), date: $0, tasks: $0.map { appointmentTasks[$0] ?? [] } ?? []) }
                return MonthItem(id: UUID(), dayItems: items)
            }
        
        // собираем недели
        let weekPadded = allDates
            .padded(toMultipleOf: 7, calendar: calendar)
        
        weeksInYear = weekPadded
            .chunked(into: 7)
            .map { weekDates in
                let items = weekDates.map { DayItem(id: UUID(), date: $0, tasks: $0.map { appointmentTasks[$0] ?? [] } ?? []) }
                return WeekItem(id: UUID(), dayItems: items)
            }
    }
    
    private func update(for taskId: UUID, and date: Date?) {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        let updatedTask = TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            endDate: date?.addingTimeInterval(3600),
            isCompleted: task.isCompleted,
            priority: task.priority,
            createdAt: task.createdAt,
            updatedAt: Date(),
            startDate: date,
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
