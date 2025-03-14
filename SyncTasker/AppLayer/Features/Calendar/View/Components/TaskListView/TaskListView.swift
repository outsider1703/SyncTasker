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
    static let sortTitle = "Sort By"
    static let filterTitle = "Filter"
}

struct TaskListView: View {
    
    // MARK: - Private Properties
    
    @Binding private var selectedFilter: TaskFilterOption
    @Binding private var errorMessage: String?
    private var taskSections: [TaskGroupSection]
    private var navigateToTaskDetail: (TaskItem?) -> Void
    private let backlogDropped: (UUID) -> Void
    
    // MARK: - Initialization
    
    init(
        taskSections: [TaskGroupSection],
        selectedFilter: Binding<TaskFilterOption>,
        errorMessage: Binding<String?>,
        navigateToTaskDetail: @escaping (TaskItem?) -> Void,
        backlogDropped: @escaping (UUID) -> Void
    ) {
        self.taskSections = taskSections
        self._selectedFilter = selectedFilter
        self._errorMessage = errorMessage
        self.navigateToTaskDetail = navigateToTaskDetail
        self.backlogDropped = backlogDropped
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Constants.navigationTitle)
                    .font(Theme.Typography.headlineFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                filterAndSorting
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 4)
            
            ScrollView(showsIndicators: false) {
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
        .dropDestination(for: String.self) { items, _ in
            guard let taskId = UUID(uuidString: items.first ?? "") else { return false }
            backlogDropped(taskId)
            return true
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
    
    private var filterAndSorting: some View {
        Menu {
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
