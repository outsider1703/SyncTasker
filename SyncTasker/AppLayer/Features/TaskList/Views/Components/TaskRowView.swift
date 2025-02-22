//
//  TaskRowView.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
}

struct TaskRowView: View {
    // MARK: - Properties
    @StateObject private var viewModel: TaskListViewModel
    private var task: TaskItem
    
    // MARK: - Initialization
    init(task: TaskItem, viewModel: TaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.task = task
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(Theme.Typography.headlineFont)
                .foregroundColor(Theme.Colors.primary)
                .strikethrough(task.isCompleted)
            
            if let dueDate = task.dueDate {
                Text(dueDate, style: .date)
                    .font(Theme.Typography.captionFont)
                    .foregroundColor(Theme.Colors.secondary)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
