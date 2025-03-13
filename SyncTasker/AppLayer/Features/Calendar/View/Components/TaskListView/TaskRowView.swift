//
//  TaskRowView.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import SwiftUI

struct TaskRowView: View {
    
    // MARK: - Private Properties
    
    private var task: TaskItem
    
    // MARK: - Initialization
    
    init(
        task: TaskItem
    ) {
        self.task = task
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(Theme.Typography.headlineFont)
                .foregroundColor(Theme.Colors.primary)
                .strikethrough(task.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let endDate = task.endDate {
                Text(endDate, style: .date)
                    .font(Theme.Typography.captionFont)
                    .foregroundColor(Theme.Colors.secondary)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape([.dragPreview], RoundedRectangle(cornerRadius: 8))
        .draggable(task.id.uuidString) {
            TaskRowView(task: task)
                .frame(width: 150)
                .background(Theme.Colors.background)
                .cornerRadius(8)
                .shadow(radius: 4)
        }
    }
}
