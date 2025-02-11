//
//  Untitled.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import SwiftUI
import CoreData

// MARK: - Constants
private enum Constants {
    static let navigationTitle = "Tasks"
    static let errorTitle = "Error"
    static let okButton = "OK"
    static let addTaskTitle = "Add Task"
    static let deleteAction = "Delete"
    static let addIcon = "plus"
    static let deleteIcon = "trash"
    static let selectTask = "Select a task"
}

struct TaskListView: View {
    // MARK: - Properties
    @StateObject var viewModel: TaskListViewModel
    private let container: DIContainer
    
    // MARK: - Initialization
    init(viewModel: TaskListViewModel, container: DIContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            mainListView
                .navigationTitle(Constants.navigationTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                    ToolbarItem { addButton }
                }
            Text(Constants.selectTask)
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
    
    // MARK: - Subviews
    private var mainListView: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task,
                           container: container,
                           onDelete: { viewModel.deleteTask(task) })
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteTask(viewModel.tasks[index])
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: { viewModel.addTask() }) {
            Label(Constants.addTaskTitle, systemImage: Constants.addIcon)
        }
    }
}

// MARK: - TaskRowView
private struct TaskRowView: View {
    let task: Task
    let container: DIContainer
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink {
            TaskDetailView(viewModel: container.makeTaskDetailViewModel(task: task))
        } label: {
            VStack(alignment: .leading, spacing: Theme.Layout.spacing / 2) {
                Text(task.title ?? "")
                    .font(Theme.Typography.headlineFont)
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(Theme.Typography.captionFont)
                        .foregroundColor(Theme.Colors.secondary)
                }
            }
            .padding(.vertical, Theme.Layout.padding / 2)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label(Constants.deleteAction, systemImage: Constants.deleteIcon)
            }
        }
    }
}
