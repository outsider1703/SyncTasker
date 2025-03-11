//
//  TaskPropertiesSection.swift
//  SyncTasker
//
//  Created by ingvar on 10.03.2025.
//

import SwiftUI

private enum Constants {
    static let priorityTitle = "Priority"
    static let repeatTitle = "Repeat"
    static let reminderTitle = "Reminder"
    static let isCompletedTitle = "Completed"
}

struct TaskPropertiesSection: View {
    
    // MARK: - Private Properties
    
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
        VStack {
            Picker(Constants.priorityTitle, selection: $priority) {
                ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                    Label(priority.title, systemImage: priority.icon)
                        .tag(priority)
                }
            }
            
            Picker(Constants.repeatTitle, selection: $repetition) {
                ForEach(TaskItem.Repetition.allCases, id: \.self) { repetition in
                    Label(repetition.rawValue, systemImage: "repeat")
                        .tag(repetition)
                }
            }
            
            Picker(Constants.reminderTitle, selection: $reminder) {
                ForEach(TaskItem.Reminder.allCases, id: \.self) { reminder in
                    Label(reminder.rawValue, systemImage: "clock")
                        .tag(reminder)
                }
            }
            
            if isEditMode {
                Toggle(Constants.isCompletedTitle, isOn: $isCompleted)
            }
        }
    }
}
