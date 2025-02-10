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
    static let errorTitle = "Error"
    static let okButton = "OK"
    static let selectItemText = "Select an item"
    static let addItemLabel = "Add Item"
    static let addItemIcon = "plus"
}

struct TaskListView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = TaskListViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            mainListView
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                    ToolbarItem { addButton }
                }
            Text(Constants.selectItemText)
        }
        .alert(Constants.errorTitle, isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } } )) {
                Button(Constants.okButton) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }
    
    // MARK: - Subviews
    private var mainListView: some View {
        List {
            ForEach(viewModel.items) { item in
                TaskRowView(item: item) { viewModel.deleteTask(item) }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteTask(viewModel.items[index])
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: { viewModel.addTask() }) {
            Label(Constants.addItemLabel, systemImage: Constants.addItemIcon)
        }
    }
}

// MARK: - TaskRowView
private struct TaskRowView: View {
    let item: Item
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: TaskDetailView(item: item)) {
            Text(item.timestamp!, formatter: itemFormatter)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
