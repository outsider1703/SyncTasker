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
    static let sortTitle = "Sort By"
    static let filterTitle = "Filter"
    static let searchPlaceholder = "Search tasks..."
    static let groupTitle = "Group By"
    static let statisticsTitle = "Statistics"
}

struct TaskListView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: TaskListViewModel
    
    // MARK: - Private Properties

    @State private var showingStats = false
    
    // MARK: - Initialization
    
    init(viewModel: TaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingStats {
                    TaskStatisticsView(statistics: viewModel.statistics)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                filterBar
                mainListView
            }
            .searchable(text: $viewModel.searchText, prompt: Constants.searchPlaceholder)
            .navigationTitle(Constants.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.statisticsTitle) { withAnimation { showingStats.toggle() } }
                }
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
    
    private var filterBar: some View {
        VStack(spacing: Theme.Layout.spacing / 2) {
            Picker(Constants.groupTitle, selection: $viewModel.selectedGrouping) {
                ForEach(TaskGroupType.allCases, id: \.self) { group in
                    Text(group.title).tag(group)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
        .padding(.vertical, Theme.Layout.padding / 2)
        .background(Theme.Colors.background)
    }
    
    private var mainListView: some View {
        List {
            ForEach(viewModel.taskSections) { section in
                if !section.title.isEmpty {
                    Section(header: Text(section.title)) { taskRows(for: section.tasks) }
                } else {
                    taskRows(for: section.tasks)
                }
            }
        }
        .animation(.default, value: viewModel.selectedGrouping)
    }
    
    private func taskRows(for tasks: [Task]) -> some View {
        ForEach(tasks) { task in
            TaskRowView(task: task)
                .onTapGesture {
                    viewModel.navigateToTaskDetail(task)
                }
        }
        .onDelete { indexSet in
            indexSet.forEach { index in
                viewModel.deleteTask(tasks[index])
            }
        }
    }
    
    private var addButton: some View {
        Button(action: { viewModel.addTask() }) {
            Label(Constants.addTaskTitle, systemImage: Constants.addIcon)
        }
    }
}
