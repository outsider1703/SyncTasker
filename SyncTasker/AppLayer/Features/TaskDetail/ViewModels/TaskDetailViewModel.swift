//
//  TaskDetailViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation

class TaskDetailViewModel: ObservableObject {
    
    // MARK: - Injections
    
    private let coreDataService: CoreDataServiceProtocol
    private let navigationService: NavigationServiceProtocol
    private let taskId: UUID
    
    // MARK: - Properties
    
    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var dueDate: Date = Date()
    @Published var isCompleted: Bool = false
    @Published var priority: TaskItem.Priority = .medium
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    init(
        task: TaskItem,
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol
    ) {
        self.taskId = task.id
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        
        // Initialize with task data
        self.title = task.title
        self.taskDescription = task.description ?? ""
        self.dueDate = task.dueDate ?? Date()
        self.isCompleted = task.isCompleted
        self.priority = task.priority
    }
    
    // MARK: - Navigation Methods
    
    func navigateBack() async {
        await navigationService.navigateBack()
    }
    
    // MARK: - Public Methods
    
    func saveTask() async {
        let updatedTask = TaskItem(
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
