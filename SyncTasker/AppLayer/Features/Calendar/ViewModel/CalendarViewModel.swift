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
        let yearComponent = calendar.component(.year, from: dateInYear)
        guard
            let firstDayOfThisYear = calendar.date(from: DateComponents(year: yearComponent, month: 1, day: 1)),
            let firstDayOfNextYear = calendar.date(from: DateComponents(year: yearComponent + 1, month: 1, day: 1)),
            let lastDayOfThisYear = calendar.date(byAdding: .day, value: -1, to: firstDayOfNextYear)
        else {
            self.monthsInYear = []
            self.weeksInYear = []
            return
        }

        let allActualDayItems = generateActualDayItems(from: firstDayOfThisYear, to: lastDayOfThisYear)
        
        self.monthsInYear = generateMonthsInYear(from: allActualDayItems)
        self.weeksInYear = generateWeeksInYear(from: allActualDayItems, firstDayOfYear: firstDayOfThisYear)
    }

    private func generateActualDayItems(from startDate: Date, to endDate: Date) -> [DayItem] {
        var actualDayItems: [DayItem] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            actualDayItems.append(DayItem(id: UUID(), date: dayStart, tasks: appointmentTasks[dayStart] ?? []))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        return actualDayItems
    }

    private func generateMonthsInYear(from actualDayItems: [DayItem]) -> [MonthItem] {
        var localMonths: [MonthItem] = []
        guard !actualDayItems.isEmpty, let firstDateInItems = actualDayItems.first?.date else { return [] }

        var currentDayItemsForMonth: [DayItem] = []
        var currentMonthComponent = calendar.component(.month, from: firstDateInItems)
        let firstSystemWeekday = calendar.firstWeekday

        let firstWeekdayOfInitialMonth = calendar.component(.weekday, from: firstDateInItems)
        var leadingPadding = (firstWeekdayOfInitialMonth - firstSystemWeekday + 7) % 7
        addEmptyDayItems(count: leadingPadding, to: &currentDayItemsForMonth)

        for dayItem in actualDayItems {
            guard let dayItemDate = dayItem.date else { continue }
            let monthOfCurrentDate = calendar.component(.month, from: dayItemDate)

            if monthOfCurrentDate != currentMonthComponent {
                if !currentDayItemsForMonth.isEmpty {
                    localMonths.append(MonthItem(id: UUID(), dayItems: currentDayItemsForMonth))
                }
                currentDayItemsForMonth = []
                currentMonthComponent = monthOfCurrentDate

                let firstWeekdayOfThisNewMonth = calendar.component(.weekday, from: dayItemDate)
                leadingPadding = (firstWeekdayOfThisNewMonth - firstSystemWeekday + 7) % 7
                addEmptyDayItems(count: leadingPadding, to: &currentDayItemsForMonth)
            }
            currentDayItemsForMonth.append(dayItem)
        }

        if !currentDayItemsForMonth.isEmpty {
            let trailingPaddingMonth = (7 - (currentDayItemsForMonth.count % 7)) % 7
            addEmptyDayItems(count: trailingPaddingMonth, to: &currentDayItemsForMonth)
            localMonths.append(MonthItem(id: UUID(), dayItems: currentDayItemsForMonth))
        }
        return localMonths
    }

    private func generateWeeksInYear(from actualDayItems: [DayItem], firstDayOfYear: Date) -> [WeekItem] {
        var localWeeks: [WeekItem] = []
        guard !actualDayItems.isEmpty else { return [] }

        var currentDayItemsForWeek: [DayItem] = []
        let firstSystemWeekday = calendar.firstWeekday
        let lastSystemWeekday = (firstSystemWeekday + 5) % 7 + 1

        let firstWeekdayOfYear = calendar.component(.weekday, from: firstDayOfYear)
        let leadingPaddingWeek = (firstWeekdayOfYear - firstSystemWeekday + 7) % 7
        addEmptyDayItems(count: leadingPaddingWeek, to: &currentDayItemsForWeek)

        for dayItem in actualDayItems {
            guard let dayItemDate = dayItem.date else { continue }
            currentDayItemsForWeek.append(dayItem)

            let weekdayOfCurrentDate = calendar.component(.weekday, from: dayItemDate)
            if weekdayOfCurrentDate == lastSystemWeekday {
                if currentDayItemsForWeek.count == 7 {
                    localWeeks.append(WeekItem(id: UUID(), dayItems: currentDayItemsForWeek))
                    currentDayItemsForWeek = []
                } else if !currentDayItemsForWeek.isEmpty {
                    let trailingPadding = (7 - (currentDayItemsForWeek.count % 7)) % 7
                    addEmptyDayItems(count: trailingPadding, to: &currentDayItemsForWeek)
                    if currentDayItemsForWeek.count == 7 {
                         localWeeks.append(WeekItem(id: UUID(), dayItems: currentDayItemsForWeek))
                    }
                    currentDayItemsForWeek = []
                }
            }
        }

        if !currentDayItemsForWeek.isEmpty {
            let trailingPaddingWeek = (7 - (currentDayItemsForWeek.count % 7)) % 7
            addEmptyDayItems(count: trailingPaddingWeek, to: &currentDayItemsForWeek)
            if currentDayItemsForWeek.count == 7 {
                localWeeks.append(WeekItem(id: UUID(), dayItems: currentDayItemsForWeek))
            }
        }
        return localWeeks
    }
    
    private func addEmptyDayItems(count: Int, to collection: inout [DayItem]) {
        for _ in 0..<count {
            collection.append(DayItem(id: UUID()))
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
