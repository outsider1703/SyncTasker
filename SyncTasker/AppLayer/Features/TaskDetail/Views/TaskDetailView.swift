//
//  TaskDetailView.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import SwiftUI

private enum Constants {
    static let navigationTitle = "Edit Task"
    static let titlePlaceholder = "Task Title"
    static let descriptionPlaceholder = "Task Description"
    static let dueDateTitle = "Due Date"
    static let priorityTitle = "Priority"
    static let isCompletedTitle = "Completed"
    static let saveButton = "Save"
    static let errorTitle = "Error"
    static let okButton = "OK"
}

struct TaskDetailView: View {
    // MARK: - Properties
    @StateObject private var viewModel: TaskDetailViewModel
    
    // MARK: - Initialization
    init(viewModel: TaskDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            Section {
                TextField(Constants.titlePlaceholder, text: $viewModel.title)
                    .font(Theme.Typography.headlineFont)
                
                TextEditor(text: $viewModel.taskDescription)
                    .font(Theme.Typography.bodyFont)
                    .frame(minHeight: 100)
                    .placeholder(when: viewModel.taskDescription.isEmpty) {
                        Text(Constants.descriptionPlaceholder)
                            .foregroundColor(Theme.Colors.secondary)
                    }
            }
            
            Section {
                DatePicker(Constants.dueDateTitle, selection: $viewModel.dueDate)
                
                Picker(Constants.priorityTitle, selection: $viewModel.priority) {
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Text(priority.title)
                            .tag(priority)
                    }
                }
                
                Toggle(Constants.isCompletedTitle, isOn: $viewModel.isCompleted)
            }
        }
        .navigationTitle(Constants.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Constants.saveButton) {
                    viewModel.saveTask()
                    viewModel.navigateBack()
                }
            }
        }
        .alert(Constants.errorTitle, isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button(Constants.okButton) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
