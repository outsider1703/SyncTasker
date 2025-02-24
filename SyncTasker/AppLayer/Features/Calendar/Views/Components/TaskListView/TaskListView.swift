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
    static let navigationTitle = "Backlog"
    static let errorTitle = "Error"
    static let okButton = "OK"
    static let addTaskTitle = "Add Task"
    static let addIcon = "plus"
    static let sortTitle = "Sort By"
    static let filterTitle = "Filter"
}

struct TaskListView: View {
    
    // MARK: - Private Properties
    
    @Binding private var selectedSortOption: TaskSortOption
    @Binding private var selectedFilter: TaskFilterOption
    @Binding private var errorMessage: String?
    private var taskSections: [TaskGroupSection]
    private var navigateToTaskDetail: (TaskItem?) -> Void
    
    // MARK: - Initialization
    
    init(
        taskSections: [TaskGroupSection],
        selectedSortOption: Binding<TaskSortOption>,
        selectedFilter: Binding<TaskFilterOption>,
        errorMessage: Binding<String?>,
        navigateToTaskDetail: @escaping (TaskItem?) -> Void
    ) {
        self.taskSections = taskSections
        self._selectedSortOption = selectedSortOption
        self._selectedFilter = selectedFilter
        self._errorMessage = errorMessage
        self.navigateToTaskDetail = navigateToTaskDetail
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: Theme.Layout.spacing) {
                        ForEach(taskSections) { section in
                            if !section.title.isEmpty {
                                Text(section.title)
                                    .font(Theme.Typography.headlineFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            ForEach(section.tasks) { task in
                                TaskRowView(task: task)
                                    .onTapGesture { navigateToTaskDetail(task) }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Constants.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { addButton }
                ToolbarItem(placement: .navigationBarLeading) { filterAndSorting }
            }
        }
        .alert(Constants.errorTitle, isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { self.errorMessage = nil } }
        )) {
            Button(Constants.okButton) { self.errorMessage = nil }
        }
        message: { Text(errorMessage ?? "") }
    }
    
    // MARK: - Subviews
    
    private var addButton: some View {
        Button(action: { navigateToTaskDetail(nil) }) {
            Label(Constants.addTaskTitle, systemImage: Constants.addIcon)
        }
    }
    
    private var filterAndSorting: some View {
        Menu {
            Picker(Constants.sortTitle, selection: $selectedSortOption) {
                ForEach(TaskSortOption.allCases, id: \.self) { option in
                    Text(option.title).tag(option)
                }
            }
            Picker(Constants.filterTitle, selection: $selectedFilter) {
                ForEach(TaskFilterOption.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}
