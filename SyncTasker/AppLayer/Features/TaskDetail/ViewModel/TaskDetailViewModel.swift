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
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var isAllDay: Bool = false
    @Published var travelTime: TravelTime = .none
    @Published var isCompleted: Bool = false
    @Published var priority: TaskItem.Priority = .medium
    @Published var repetition: TaskItem.Repetition = .none
    @Published var reminder: TaskItem.Reminder = .none
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
        
        if let task {
            self.title = task.title
            self.taskDescription = task.description ?? ""
            self.startDate = task.startDate
            self.endDate = task.endDate ?? startDate?.addingTimeInterval(3600)
            self.isCompleted = task.isCompleted
            self.priority = task.priority
            self.repetition = task.repetition
            self.reminder = task.reminder
        }
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() async {
        await navigationService.navigateBack()
    }
    
    // MARK: - Public Methods
    
    func createOrEditTask() async {
        guard !title.isEmpty else {
            await MainActor.run { errorMessage = "Title cannot be empty" }
            return
        }
        
        let task = TaskItem(
            id: existingTask?.id ?? UUID(),
            title: title,
            description: taskDescription.isEmpty ? nil : taskDescription,
            endDate: endDate,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: existingTask?.createdAt ?? Date(),
            updatedAt: Date(),
            startDate: startDate,
            isAllDay: isAllDay,
            travelTime: Calendar.current.date(byAdding: .minute, value: -travelTime.minutes, to: startDate ?? Date())
        )
        
        do {
            isEditMode ? try coreDataService.updateTask(task) : try coreDataService.createTask(task)
            await dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
