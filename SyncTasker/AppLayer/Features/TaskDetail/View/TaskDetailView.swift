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
                TaskTitleSection(
                    title: $viewModel.title,
                    description: $viewModel.taskDescription
                )
                
                TaskDatesSection(
                    startDate: $viewModel.startDate,
                    endDate: $viewModel.endDate,
                    isAllDay: $viewModel.isAllDay,
                    travelTime: $viewModel.travelTime
                )
                
                TaskPropertiesSection(
                    priority: $viewModel.priority,
                    repetition: $viewModel.repetition,
                    reminder: $viewModel.reminder,
                    isCompleted: $viewModel.isCompleted,
                    isEditMode: viewModel.isEditMode
                )
            }
            .navigationTitle(viewModel.isEditMode ? Constants.editTitle : Constants.createTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Constants.cancelButton) { Task { await viewModel.dismiss() } }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.saveButton) { Task { await viewModel.createOrEditTask() } }
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
