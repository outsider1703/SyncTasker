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
                
                ScrollView {
                    LazyVStack(spacing: Theme.Layout.spacing) {
                        ForEach(viewModel.taskSections) { section in
                            if !section.title.isEmpty {
                                Text(section.title)
                                    .font(Theme.Typography.headlineFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            taskRows(for: section.tasks)
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $viewModel.searchText, prompt: Constants.searchPlaceholder)
            .navigationTitle(Constants.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.statisticsTitle) { 
                        withAnimation { showingStats.toggle() } 
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { 
                    Menu {
                        Picker(Constants.sortTitle, selection: $viewModel.selectedSortOption) {
                            ForEach(TaskSortOption.allCases, id: \.self) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        
                        Picker(Constants.filterTitle, selection: $viewModel.selectedFilter) {
                            ForEach(TaskFilterOption.allCases, id: \.self) { filter in
                                Text(filter.title).tag(filter)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
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
    
    private func taskRows(for tasks: [TaskItem]) -> some View {
        ForEach(tasks) { task in
            TaskRowView(task: task, viewModel: viewModel)
                .onTapGesture {
                    viewModel.navigateToTaskDetail(task)
                }
        }
    }
    
    private var addButton: some View {
        Button(action: { viewModel.addTask() }) {
            Label(Constants.addTaskTitle, systemImage: Constants.addIcon)
        }
    }
}
