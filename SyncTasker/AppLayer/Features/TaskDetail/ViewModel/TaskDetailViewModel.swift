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
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(3600) // Конец по умолчанию через час
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
        
        if let task = task {
            self.title = task.title
            self.taskDescription = task.description ?? ""
            
            // Инициализируем новые поля на основе существующей задачи
            // Для обратной совместимости используем старые поля
            // В будущем модель TaskItem нужно будет также обновить
            if let appointmentDate = task.appointmentDate {
                self.startDate = appointmentDate
                self.endDate = task.dueDate ?? appointmentDate.addingTimeInterval(3600)
            } else {
                self.startDate = task.dueDate ?? Date()
                self.endDate = (task.dueDate ?? Date()).addingTimeInterval(3600)
            }
            
            self.isCompleted = task.isCompleted
            self.priority = task.priority
        }
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() async {
        await navigationService.navigateBack()
    }
        
    // MARK: - Helper Methods
    
    func setAllDayTimes() {
        if isAllDay {
            // Устанавливаем время начала на 00:00
            let calendar = Calendar.current
            var startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
            startComponents.hour = 0
            startComponents.minute = 0
            startComponents.second = 0
            
            // Устанавливаем время конца на 23:59
            var endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
            endComponents.hour = 23
            endComponents.minute = 59
            endComponents.second = 59
            
            if let newStartDate = calendar.date(from: startComponents) {
                startDate = newStartDate
            }
            
            if let newEndDate = calendar.date(from: endComponents) {
                endDate = newEndDate
            }
        }
    }
    
    // MARK: - Public Methods
    
    func createOrEditTask() async {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty"
            return
        }

        // Установить корректное время для режима 'весь день'
        if isAllDay {
            setAllDayTimes()
        }

        let task = TaskItem(
            id: existingTask?.id ?? UUID(),
            title: title,
            description: taskDescription.isEmpty ? nil : taskDescription,
            dueDate: endDate, // Используем endDate вместо dueDate
            isCompleted: isCompleted,
            priority: priority,
            createdAt: existingTask?.createdAt ?? Date(),
            updatedAt: Date(),
            appointmentDate: startDate // Используем startDate вместо appointmentDate
            // В будущем можно добавить поля isAllDay и travelTime в модель TaskItem
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
