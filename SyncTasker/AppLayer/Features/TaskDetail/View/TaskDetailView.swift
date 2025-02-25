//
//  TaskDetailView.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import SwiftUI

private enum Constants {
    static let createTitle = "Create Task"
    static let editTitle = "Edit Task"
    static let titlePlaceholder = "Task Title"
    static let descriptionPlaceholder = "Task Description"
    static let dueDateTitle = "Due Date"
    static let appointmentDateTitle = "Appointment Date"
    static let priorityTitle = "Priority"
    static let isCompletedTitle = "Completed"
    static let saveButton = "Save"
    static let cancelButton = "Cancel"
    static let errorTitle = "Error"
    static let okButton = "OK"
}

struct TaskDetailView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: TaskDetailViewModel
    
    // MARK: - Initialization
    
    init(
        viewModel: TaskDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                TaskTitleSection(title: $viewModel.title, description: $viewModel.taskDescription)
                TaskDatesSection(appointmentDate: $viewModel.appointmentDate, dueDate: $viewModel.dueDate)
                TaskPropertiesSection(priority: $viewModel.priority, isCompleted: $viewModel.isCompleted, isEditMode: viewModel.isEditMode)
            }
            .navigationTitle(viewModel.isEditMode ? Constants.editTitle : Constants.createTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Constants.cancelButton) {
                        Task { await viewModel.dismiss() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.saveButton) {
                        Task { await viewModel.createOrEditTask() }
                    }
                }
            }
            .alert(Constants.errorTitle, isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) { Button(Constants.okButton) { viewModel.errorMessage = nil } }
            message: { Text(viewModel.errorMessage ?? "") }
        }
    }
}

// MARK: - Title Section View

struct TaskTitleSection: View {
    
    @Binding var title: String
    @Binding var description: String
    
    init(
        title: Binding<String>,
        description: Binding<String>
    ) {
        self._title = title
        self._description = description
    }
    
    var body: some View {
        Section {
            TextField(Constants.titlePlaceholder, text: $title)
                .font(Theme.Typography.headlineFont)
            
            TextEditor(text: $description)
                .font(Theme.Typography.bodyFont)
                .frame(minHeight: 100)
                .placeholder(when: description.isEmpty) {
                    Text(Constants.descriptionPlaceholder)
                        .foregroundColor(Theme.Colors.secondary)
                }
        }
    }
}

// MARK: - Dates Section View

struct TaskDatesSection: View {
    @Binding var appointmentDate: Date?
    @Binding var dueDate: Date
    @State private var showDatePicker = false
    
    init(
        appointmentDate: Binding<Date?>,
        dueDate: Binding<Date>
    ) {
        self._appointmentDate = appointmentDate
        self._dueDate = dueDate
    }
    
    var body: some View {
        Section {
            HStack {
                Text(Constants.appointmentDateTitle)
                Spacer()
                
                HStack(spacing: 8) {
                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { appointmentDate ?? Date() },
                                set: { appointmentDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .frame(width: 120)
                    } else {
                        Text(appointmentDate?.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                            .foregroundColor(appointmentDate == nil ? .blue : .primary)
                            .onTapGesture {
                                if appointmentDate == nil {
                                    appointmentDate = Date()
                                }
                                showDatePicker = true
                            }
                    }
                    
                    if appointmentDate != nil {
                        Button(action: {
                            appointmentDate = nil
                            showDatePicker = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            DatePicker(
                Constants.dueDateTitle,
                selection: $dueDate,
                in: (appointmentDate ?? Date())...,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
}

// MARK: - Properties Section View

struct TaskPropertiesSection: View {
    
    @Binding var priority: TaskItem.Priority
    @Binding var isCompleted: Bool
    let isEditMode: Bool
    
    init(
        priority: Binding<TaskItem.Priority>,
        isCompleted: Binding<Bool>,
        isEditMode: Bool
    ) {
        self._priority = priority
        self._isCompleted = isCompleted
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        Section {
            Picker(Constants.priorityTitle, selection: $priority) {
                ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                    Label(priority.title, systemImage: priority.icon)
                        .tag(priority)
                }
            }
            
            if isEditMode {
                Toggle(Constants.isCompletedTitle, isOn: $isCompleted)
            }
        }
    }
}
