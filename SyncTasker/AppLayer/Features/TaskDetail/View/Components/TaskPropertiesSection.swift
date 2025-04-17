//
//  TaskPropertiesSection.swift
//  SyncTasker
//
//  Created by ingvar on 10.03.2025.
//

import SwiftUI

private enum Constants {
    static let priorityTitle = "Приоритет"
    static let repeatTitle = "Повторение задачи"
    static let reminderTitle = "Напоминание"
    static let isCompletedTitle = "Выполнено"
}

struct TaskPropertiesSection: View {
    
    // MARK: - Initial Private Properties
    
    @Binding private var priority: TaskItem.Priority
    @Binding private var repetition: TaskItem.Repetition
    @Binding private var reminder: TaskItem.Reminder
    @Binding private var isCompleted: Bool
    private let isEditMode: Bool
    
    // MARK: - Initialization
    
    init(
        priority: Binding<TaskItem.Priority>,
        repetition: Binding<TaskItem.Repetition>,
        reminder: Binding<TaskItem.Reminder>,
        isCompleted: Binding<Bool>,
        isEditMode: Bool
    ) {
        self._priority = priority
        self._repetition = repetition
        self._reminder = reminder
        self._isCompleted = isCompleted
        self.isEditMode = isEditMode
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            CustomPicker(selection: $priority, Constants.priorityTitle) {
                ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                    Label(priority.title, systemImage: priority.icon)
                        .tag(priority)
                }
            }
            
            CustomPicker(selection: $repetition, Constants.repeatTitle) {
                ForEach(TaskItem.Repetition.allCases, id: \.self) { repetition in
                    Label(repetition.rawValue, systemImage: "repeat")
                        .tag(repetition)
                }
            }
            
            CustomPicker(selection: $reminder, Constants.reminderTitle) {
                ForEach(TaskItem.Reminder.allCases, id: \.self) { reminder in
                    Label(reminder.rawValue, systemImage: "clock")
                        .tag(reminder)
                }
            }
            
            if isEditMode {
                Toggle(Constants.isCompletedTitle, isOn: $isCompleted)
                    .padding(.vertical, 8)
            }
        }
    }
}
