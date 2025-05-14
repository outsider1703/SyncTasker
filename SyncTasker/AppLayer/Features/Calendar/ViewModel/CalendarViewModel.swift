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
    @Published var errorMessage: String?
    @Published var calendarViewType: CalendarViewType = .month

    @Published var appointmentTasks: [Date: [TaskItem]] = [:]
    @Published var backlogTasks: [TaskItem] = []
    @Published var selectedFilter: TaskFilterOption = .all
    @Published var currentMonth = Date()
    
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
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTaskDetail(_ task: TaskItem?) {
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
        guard let firstDayFromSelectedMonth = month.dayItems.first(where: { $0.date != nil })?.date else { return }
        let isCurrentMonth = calendar.dateComponents([.month], from: firstDayFromSelectedMonth) == calendar.dateComponents([.month], from: Date())
        currentMonth = isCurrentMonth ? Date() : firstDayFromSelectedMonth
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
        guard let yearInterval = calendar.dateInterval(of: .year, for: dateInYear) else {
            self.monthsInYear = []
            self.weeksInYear = []
            return
        }

        var localMonths: [MonthItem] = []
        var localWeeks: [WeekItem] = []

        var currentDayItemsForMonthDisplay: [DayItem] = []
        var currentDayItemsForWeek: [DayItem] = []

        var currentDate = yearInterval.start
        var currentMonthComponent = calendar.component(.month, from: currentDate)

        let firstSystemWeekday = calendar.firstWeekday
        let lastSystemWeekday = (firstSystemWeekday + 5) % 7 + 1

        let firstWeekdayOfInitialMonth = calendar.component(.weekday, from: currentDate)
        var leadingPaddingCount = (firstWeekdayOfInitialMonth - firstSystemWeekday + 7) % 7
        for _ in 0..<leadingPaddingCount {
            currentDayItemsForMonthDisplay.append(DayItem(id: UUID()))
        }
        
        while currentDate <= yearInterval.end {
            let dayStart = calendar.startOfDay(for: currentDate)
            let actualDayItem = DayItem(id: UUID(), date: dayStart, tasks: appointmentTasks[dayStart])

            // --- Month Processing ---
            let monthOfCurrentDate = calendar.component(.month, from: currentDate)
            if monthOfCurrentDate != currentMonthComponent {
                if !currentDayItemsForMonthDisplay.isEmpty {
                     localMonths.append(MonthItem(id: UUID(), dayItems: currentDayItemsForMonthDisplay))
                }
                currentDayItemsForMonthDisplay = []
                currentMonthComponent = monthOfCurrentDate

                let firstWeekdayOfThisNewMonth = calendar.component(.weekday, from: currentDate)
                leadingPaddingCount = (firstWeekdayOfThisNewMonth - firstSystemWeekday + 7) % 7
                for _ in 0..<leadingPaddingCount {
                    currentDayItemsForMonthDisplay.append(DayItem(id: UUID()))
                }
            }
            currentDayItemsForMonthDisplay.append(actualDayItem)

            // --- Week Processing ---
            currentDayItemsForWeek.append(actualDayItem)
            
            let weekdayOfCurrentDate = calendar.component(.weekday, from: currentDate)
            if weekdayOfCurrentDate == lastSystemWeekday || currentDate == yearInterval.end {
                if !currentDayItemsForWeek.isEmpty {
                    localWeeks.append(WeekItem(id: UUID(), dayItems: currentDayItemsForWeek))
                    currentDayItemsForWeek = []
                }
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        self.monthsInYear = localMonths
        self.weeksInYear = localWeeks
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
