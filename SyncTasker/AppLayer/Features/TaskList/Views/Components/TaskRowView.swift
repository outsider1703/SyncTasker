//
//  TaskRowView.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let deleteAction = "Delete"
    static let deleteIcon = "trash"
    static let checkmarkIcon = "checkmark.circle.fill"
}

struct TaskRowView: View {
    let task: Task
    let container: DIContainer
    let onDelete: () -> Void
    
    @State private var isSwipeActive = false
    @State private var isPressed = false
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return Theme.Colors.priorityLow
        case .medium: return Theme.Colors.priorityMedium
        case .high: return Theme.Colors.priorityHigh
        }
    }
    
    var body: some View {
        NavigationLink {
            TaskDetailView(viewModel: container.makeTaskDetailViewModel(task: task))
        } label: {
            HStack(spacing: Theme.Layout.spacing) {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: Theme.Layout.spacing / 2) {
                    Text(task.title)
                        .font(Theme.Typography.headlineFont)
                        .foregroundColor(Theme.Colors.primary)
                        .strikethrough(task.isCompleted)
                    
                    if let dueDate = task.dueDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.Colors.secondary)
                            Text(dueDate, style: .date)
                                .font(Theme.Typography.captionFont)
                                .foregroundColor(Theme.Colors.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if task.isCompleted {
                    Image(systemName: Constants.checkmarkIcon)
                        .foregroundColor(Theme.Colors.success)
                        .withFadeAnimation(isAnimating: task.isCompleted)
                }
            }
            .padding(.vertical, Theme.Layout.padding / 2)
            .padding(.horizontal, Theme.Layout.padding)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.primary.opacity(0.05), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .contentShape(Rectangle())
            .withHapticFeedback(style: .medium) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: {
                FeedbackManager.shared.impact(style: .heavy)
                withAnimation { onDelete() }
            }) {
                Label(Constants.deleteAction, systemImage: Constants.deleteIcon)
            }
        }
        .onChange(of: isSwipeActive) { newValue in
            if newValue { FeedbackManager.shared.impact(style: .light) }
        }
        .withSlideAnimation(isAnimating: true)
    }
}
