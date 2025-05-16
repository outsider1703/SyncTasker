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
    static let filterTitle = "Filter"
}

struct TaskListView: View {
    
    // MARK: - Initial Private Properties
    
    @Binding private var selectedFilter: TaskFilterOption
    @Binding private var errorMessage: String?
    private var taskSections: [TaskGroupSection]
    private var navigateToTaskDetail: (TaskItem?) -> Void
    private let backlogDropped: (UUID) -> Void
    
    // MARK: - Initialization
    
    init(
        selectedFilter: Binding<TaskFilterOption>,
        errorMessage: Binding<String?>,
        taskSections: [TaskGroupSection],
        navigateToTaskDetail: @escaping (TaskItem?) -> Void,
        backlogDropped: @escaping (UUID) -> Void
    ) {
        self._selectedFilter = selectedFilter
        self._errorMessage = errorMessage
        self.taskSections = taskSections
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

#if DEBUG
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
