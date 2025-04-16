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
    
    @Published var daysInYear: [[DayItem]] = []
    @Published var listDaysInMonth: [DayItem] = []
    
    @Published var tasks: [TaskItem] = []
    @Published var appointmentTasks: [Date: [TaskItem]] = [:]
    @Published var backlogTasks: [TaskItem] = []
    @Published var errorMessage: String?
    @Published var selectedFilter: TaskFilterOption = .all
    @Published var calendarViewType: CalendarViewType = .month
    @Published var selectedDate = Date()
    @Published var currentMoutn = Date()

    // MARK: - Computed Properties
    
    var statistics: TaskStatistics { TaskStatistics(tasks: tasks) }
    var taskSections: [TaskGroupSection] {
        let filtered = backlogTasks.filter { selectedFilter.filter($0) }
        return TaskGroupSection.group(filtered)
    }
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private var currentYear: [[DayItem]] = [] {
        didSet {
            daysInYear = currentYear.map({ $0.filter({ $0.type == .day || $0.type == .yearSpacing }) })
            listDaysInMonth = currentYear.flatMap({ $0 }).filter({ $0.type == .day || $0.type == .monthSpacing })
        }
    }

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
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTaskDetail(_ task: TaskItem?) {
        Task { await navigationService.navigate(to: .taskDetail(task)) }
    }
    
    func navigateToDailySchedule(_ date: Date?, _ tasks: [TaskItem]) {
        guard let date else { return }
        Task { await navigationService.navigate(to: .dailySchedule(date, tasks)) }
    }
    
    func navigateToFreeTime() {
        Task { await navigationService.navigate(to: .freeTime) }
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
    
    func didTapMonth(with month: [DayItem]) {
        calendarViewType = .month
        guard let firstDayFromSelectedMonth = month.first(where: { $0.type == .day })?.date else { return }
        let isCurrentMonth = calendar.dateComponents([.month], from: firstDayFromSelectedMonth) == calendar.dateComponents([.month], from: Date())
        currentMoutn = isCurrentMonth ? Date() : firstDayFromSelectedMonth
    }
    
    // MARK: - Private Methods
    
    private func getMonthsInYear() {
        let interval = calendar.dateInterval(of: .year, for: Date())!
        var startDate = interval.start
        var months: [[DayItem]] = []
        
        while startDate < interval.end {
            let daysInMonth = generateDaysForMonth(startDate)
            months.append(daysInMonth)
            startDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        }
        
        currentYear = months
    }
    
    private func generateDaysForMonth(_ month: Date) -> [DayItem] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let daysRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
        else { return [] }
        
        var days: [DayItem] = []
        
        // Создаются пустые дни ( отступы ) в начале месяца для отображения экрана года
        let firstWeekday = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7 + 1
        for _ in 1..<firstWeekday { days.append(DayItem(id: UUID(), type: .yearSpacing)) }
        
        // Создается пустой день перед началом месяца для отображения в списке дней
        days.append(DayItem(id: UUID(), type: .monthSpacing))
        
        // Добавляем обычны дни со списком задач для каждого дня
        for day in daysRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DayItem(id: UUID(), type: .day, date: date, tasks: appointmentTasks[date]))
            }
        }
        
        return days
    }

    private func loadTasks() {
        do {
            try fetchController.performFetch()
            tasks = (fetchController.fetchedObjects ?? []).map { $0.toTask() }
            let groupedTasks = tasks.groupByAppointmentDate()
            
            appointmentTasks = groupedTasks.appointmentTasks
            backlogTasks = groupedTasks.backlogTasks
            getMonthsInYear()
        } catch {
            errorMessage = error.localizedDescription
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
}

// MARK: - NSFetchedResultsControllerDelegate

extension CalendarViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadTasks()
    }
}
