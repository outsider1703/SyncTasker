//
//  CalendarViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import Foundation
import CoreData
import Combine

@MainActor
class CalendarViewModel: NSObject, ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    private let fetchController: NSFetchedResultsController<TaskEntity>
    private let navigationService: NavigationServiceProtocol
    private let feedbackManager: FeedbackManager
    private let sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol

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
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    
    init(
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol,
        feedbackManager: FeedbackManager,
        sleepInstructionUpdateService: SleepInstructionUpdateServiceProtocol
    ) {
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        self.feedbackManager = feedbackManager
        self.sleepInstructionUpdateService = sleepInstructionUpdateService

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
        Task {
            await self.loadTasks()
            self.setupWeekIndex(for: monthsInYear.first(where: { $0.isCurrentMonth }))
        }
        subscribeToSleepInstructionUpdates()
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
        Task { await update(for: task, and: date) }
    }
    
    func deleteTask(_ task: TaskItem) async {
        do {
            try await coreDataService.delete(task)
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
    
    private func subscribeToSleepInstructionUpdates() {
        sleepInstructionUpdateService.updatePublisher
            .sink { [weak self] in
                guard let self else { return }
                Task {
                    await self.loadTasks()
                }
            }
            .store(in: &cancellables)
    }

    private func loadTasks() async {
        do {
            try fetchController.performFetch()
            tasks = (fetchController.fetchedObjects ?? []).map { $0.toTask() }
            let groupedTasks = tasks.groupByDailyTasks()
            dailyTasks = groupedTasks.dailyTasks
            backlogTasks = groupedTasks.backlogTasks
            
            if let sleepInstruction = try await getSleepInstruction() {
                setupCalendarData(for: Date(), using: sleepInstruction)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func getSleepInstruction() async throws -> SleepInstruction? {
        if UserDefaults.standard.string(forKey: "userId") != nil {
            return try await coreDataService.fetchSleepInstructions()?.first
        } else {
            let userId = UUID()
            UserDefaults.standard.setValue(userId.uuidString, forKey: "userId")
            let defaultInstruction = SleepInstruction(
                id: userId,
                weekdayPeriod: SleepPeriod(startSleepTeme: 390, endSleepTime: 1200) ,
                weekendPeriod: SleepPeriod(startSleepTeme: 600, endSleepTime: 1340) ,
                specialDates: [Date().toKey() : SleepPeriod(startSleepTeme: 720, endSleepTime: 1000)])
            
            try await coreDataService.createSleepInstruction(defaultInstruction)
            return defaultInstruction
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
            let morning = TaskItem(title: "sleep", startDate: day.startTime(), endDate: day.at(period.startSleepTeme))
            let evening = TaskItem(title: "sleep", startDate: day.at(period.endSleepTime), endDate: day.endTime())
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
    
    private func update(for taskId: UUID, and date: Date?) async {
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
            try await coreDataService.updateTask(updatedTask)
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
    
    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task { @MainActor in
            await loadTasks()
        }
    }
}
