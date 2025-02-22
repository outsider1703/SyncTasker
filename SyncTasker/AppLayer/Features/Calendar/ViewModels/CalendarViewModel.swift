//
//  CalendarViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import Foundation
import CoreData

class CalendarViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let coreDataService: CoreDataServiceProtocol
    private let fetchController: NSFetchedResultsController<TaskEntity>
    private let navigationService: NavigationServiceProtocol
    let feedbackManager: FeedbackManager
    
    @Published var tasks: [TaskItem] = []
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedSortOption: TaskSortOption = .createdAt
    @Published var selectedFilter: TaskFilterOption = .all
    @Published var selectedGrouping: TaskGroupType = .none
    
    // MARK: - Computed Properties
    
    var statistics: TaskStatistics { TaskStatistics(tasks: tasks) }
    
    var taskSections: [TaskGroupSection] {
        let filtered = tasks.filter { task in
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
    
    init(coreDataService: CoreDataServiceProtocol,
         navigationService: NavigationServiceProtocol,
         feedbackManager: FeedbackManager) {
        
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
    
    func navigateToTaskDetail(_ task: TaskItem) {
        Task {
            await navigationService.navigate(to: .taskDetail(task))
        }
    }
    
    // MARK: - Public Methods
    
    func applySort(_ option: TaskSortOption) { selectedSortOption = option }
    func applyFilter(_ filter: TaskFilterOption) { selectedFilter = filter }
    func applyGrouping(_ type: TaskGroupType) { selectedGrouping = type }

    func addTask() {
        let task = TaskItem(title: "New Task")
        do {
            let taskEntity = coreDataService.createTask()
            taskEntity.update(from: task)
            try coreDataService.saveContext()
        } catch {
            errorMessage = error.localizedDescription
        }
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
            tasks = (fetchController.fetchedObjects ?? []).map { $0.toTask() }
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
