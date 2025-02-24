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
    
    // MARK: - Properties
    
    @Published var tasks: [TaskItem] = []
    @Published var appointmentTasks: [Date: [TaskItem]] = [:]
    @Published var backlogTasks: [TaskItem] = []
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedSortOption: TaskSortOption = .createdAt
    @Published var selectedFilter: TaskFilterOption = .all
    @Published var selectedGrouping: TaskGroupType = .none
    
    // MARK: - Computed Properties
    
    var dailyTasks: [Date: [TaskItem]] { appointmentTasks }
    
    var statistics: TaskStatistics { TaskStatistics(tasks: tasks) }
    
    var taskSections: [TaskGroupSection] {
        let filtered = backlogTasks.filter { task in
            if !searchText.isEmpty {
                return task.title.localizedCaseInsensitiveContains(searchText) || task.description?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            return selectedFilter.filter(task)
        }
        
        let sorted = filtered.sorted { task1, task2 in
            switch selectedSortOption {
            case .createdAt:
                return task1.createdAt > task2.createdAt
            case .dueDate:
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else {
                    return (task1.dueDate != nil) ? true : false
                }
                return date1 < date2
            case .priority:
                return task1.priority.rawValue > task2.priority.rawValue
            case .title:
                return task1.title < task2.title
            }
        }
        
        return TaskGroupSection.group(sorted, by: selectedGrouping)
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
    
    // MARK: - Public Methods
    
    func applySort(_ option: TaskSortOption) { selectedSortOption = option }
    func applyFilter(_ filter: TaskFilterOption) { selectedFilter = filter }
    func applyGrouping(_ type: TaskGroupType) { selectedGrouping = type }
    
    func updateTaskDate(task: UUID, to date: Date) {
        update(for: task, and: date)
    }
    
    func deleteTask(_ task: TaskItem) {
        do {
            if let taskToDelete = fetchController.fetchedObjects?.first(where: { $0.id == task.id }) {
                try coreDataService.delete(taskToDelete)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTasks() {
        do {
            try fetchController.performFetch()
            let allTasks = (fetchController.fetchedObjects ?? []).map { $0.toTask() }
            let groupedTasks = allTasks.groupByAppointmentDate()
            
            tasks = allTasks
            appointmentTasks = groupedTasks.appointmentTasks
            backlogTasks = groupedTasks.backlogTasks
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func update(for taskId: UUID, and date: Date) {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        let updatedTask = TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            dueDate: task.dueDate,
            isCompleted: task.isCompleted,
            priority: task.priority,
            createdAt: task.createdAt,
            updatedAt: Date(),
            appointmentDate: date
        )
        
        do {
            if let taskEntity = try coreDataService.fetchTasks().first(where: { $0.id == task.id }) {
                taskEntity.update(from: updatedTask)
                try coreDataService.saveContext()
            }
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
