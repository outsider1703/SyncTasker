//
//  TaskListViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation
import CoreData

class TaskListViewModel: NSObject, ObservableObject {
    // MARK: - Properties
    private let coreDataService: CoreDataServiceProtocol
    private let fetchController: NSFetchedResultsController<TaskEntity>
    
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        
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
    
    // MARK: - Public Methods
    func addTask() {
        let task = Task(title: "New Task")
        do {
            let taskEntity = coreDataService.createTask()
            taskEntity.update(from: task)
            try coreDataService.saveContext()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTask(_ task: Task) {
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
extension TaskListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadTasks()
    }
}
