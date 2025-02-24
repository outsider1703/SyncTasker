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
    private let existingTask: TaskItem?
    
    // MARK: - Properties
    
    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var dueDate: Date = Date()
    @Published var appointmentDate: Date?
    @Published var isCompleted: Bool = false
    @Published var priority: TaskItem.Priority = .medium
    @Published var errorMessage: String?
    
    var isEditMode: Bool { existingTask != nil }
    
    // MARK: - Initialization
    
    init(
        task: TaskItem? = nil,
        coreDataService: CoreDataServiceProtocol,
        navigationService: NavigationServiceProtocol
    ) {
        self.existingTask = task
        self.coreDataService = coreDataService
        self.navigationService = navigationService
        
        if let task = task {
            self.title = task.title
            self.taskDescription = task.description ?? ""
            self.dueDate = task.dueDate ?? Date()
            self.appointmentDate = task.appointmentDate
            self.isCompleted = task.isCompleted
            self.priority = task.priority
        }
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() async {
        await navigationService.navigateBack()
    }
        
    // MARK: - Public Methods
    
    func createOrEditTask() async {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty"
            return
        }

        let task = TaskItem(
            id: existingTask?.id ?? UUID(),
            title: title,
            description: taskDescription.isEmpty ? nil : taskDescription,
            dueDate: dueDate,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: existingTask?.createdAt ?? Date(),
            updatedAt: Date(),
            appointmentDate: appointmentDate
        )
        
        do {
            if let existingTask = existingTask, let taskEntity = try coreDataService.fetchTasks().first(where: { $0.id == existingTask.id }) {
                taskEntity.update(from: task)
                try coreDataService.saveContext()
            } else {
                try coreDataService.createTask(task)
            }
            await dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
