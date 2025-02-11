//
//  TaskDetailViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation

class TaskDetailViewModel: ObservableObject {
    // MARK: - Properties
    private let coreDataService: CoreDataServiceProtocol
    private let taskId: UUID
    
    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var dueDate: Date = Date()
    @Published var isCompleted: Bool = false
    @Published var priority: Task.Priority = .medium
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init(task: Task, coreDataService: CoreDataServiceProtocol) {
        self.taskId = task.id
        self.coreDataService = coreDataService
        
        // Initialize with task data
        self.title = task.title ?? ""
        self.taskDescription = task.description ?? ""
        self.dueDate = task.dueDate ?? Date()
        self.isCompleted = task.isCompleted
        self.priority = task.priority
    }
    
    // MARK: - Public Methods
    func saveTask() {
        let updatedTask = Task(
            id: taskId,
            title: title,
            description: taskDescription.isEmpty ? nil : taskDescription,
            dueDate: dueDate,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            if let taskEntity = try coreDataService.fetchTasks().first(where: { $0.id == taskId }) {
                taskEntity.update(from: updatedTask)
                try coreDataService.saveContext()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
