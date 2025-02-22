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
    
    // MARK: - Private Properties
    
    @State private var showingStats = false
    private var taskSections: [TaskGroupSection]
    
    // MARK: - Initialization
    
    init(taskSections: [TaskGroupSection]) {
        self.taskSections = taskSections
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //filterBar
                
                ScrollView {
                    LazyVStack(spacing: Theme.Layout.spacing) {
                        ForEach(taskSections) { section in
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
            .navigationTitle(Constants.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem { addButton } }
        }
    }
    
    // MARK: - Subviews
    
    //    private var filterBar: some View {
    //        VStack(spacing: Theme.Layout.spacing / 2) {
    //            Picker(Constants.groupTitle, selection: $viewModel.selectedGrouping) {
    //                ForEach(TaskGroupType.allCases, id: \.self) { group in
    //                    Text(group.title).tag(group)
    //                }
    //            }
    //            .pickerStyle(.segmented)
    //            .padding(.horizontal)
    //        }
    //        .padding(.vertical, Theme.Layout.padding / 2)
    //        .background(Theme.Colors.background)
    //    }
    
    private func taskRows(for tasks: [TaskItem]) -> some View {
        ForEach(tasks) { task in
            TaskRowView(task: task)
                .onTapGesture {
                    //viewModel.navigateToTaskDetail(task)
                }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            //viewModel.addTask()
        }) {
            Label(Constants.addTaskTitle, systemImage: Constants.addIcon)
        }
    }
}
