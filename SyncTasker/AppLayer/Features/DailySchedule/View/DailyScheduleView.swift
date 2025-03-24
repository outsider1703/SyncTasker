//
//  DailyScheduleView.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let taskCornerRadius: CGFloat = 8
    static let hourRowHeight: CGFloat = 60
    static let timeColumnWidth: CGFloat = 50
    static let taskMinWidth: CGFloat = 100
}

struct DailyScheduleView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: DailyScheduleViewModel
    
    // MARK: - Private Properties
    
    // MARK: - Initialization
    
    init(
        viewModel: DailyScheduleViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.allDayTasks.isEmpty {
                allDayTasksSection
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        hourRowView(for: hour)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.navigationTitle)
    }
    
    // MARK: - All Day Tasks Section
    
    private var allDayTasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("весь день")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.allDayTasks) { task in
                HStack {
                    Text(task.title)
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemBackground))
                .cornerRadius(Constants.taskCornerRadius)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Hour Row View
    
    private func hourRowView(for hour: Int) -> some View {
        let tasksWithOffsets = viewModel.tasksForHour(hour)
        
        return ZStack(alignment: .leading) {
            // Background with time and divider
            HStack(spacing: 0) {
                Text(String(format: "%02d:00", hour))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: Constants.timeColumnWidth, alignment: .center)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
            }
            
            // Tasks layer
            HStack(spacing: 0) {
                // Spacing for time column
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: Constants.timeColumnWidth)
                
                // Tasks
                ZStack(alignment: .topLeading) {
                    ForEach(tasksWithOffsets, id: \.0.id) { task, offset in
                        TaskView(task: task, viewModel: viewModel, hour: hour)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: Constants.hourRowHeight)
    }
    
    // MARK: - Task View
    
    private struct TaskView: View {
        let task: TaskItem
        let viewModel: DailyScheduleViewModel
        let hour: Int
        
        var body: some View {
            Text(task.title)
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(width: Constants.taskMinWidth, alignment: .leading)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(Constants.taskCornerRadius)
                .frame(height: viewModel.taskHeight(for: task))
                .offset(y: viewModel.taskTopOffset(for: task, in: hour))
        }
    }
}
