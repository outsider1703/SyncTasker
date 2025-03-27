//
//  DailyScheduleView.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let taskCornerRadius: CGFloat = 12
    static let hourRowHeight: CGFloat = 60
    static let timeColumnWidth: CGFloat = 24
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
            
            ScrollView(showsIndicators: false) {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        // Часовая сетка
                        VStack(spacing: 0) {
                            ForEach(0..<24) { hour in
                                HStack(alignment: .top, spacing: 0) {
                                    VStack {
                                        Text(String(format: "%02d", hour))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .frame(width: Constants.timeColumnWidth)
                                    .padding(.top, 4)
                                    
                                    Rectangle()
                                        .fill(.gray.opacity(0.2))
                                        .frame(height: 1)
                                }
                                .frame(height: Constants.hourRowHeight)
                            }
                        }
                        
                        // Задачи
                        ForEach(viewModel.dailyTasks, id: \.task.id) { task in
                            TaskView(dailyTask: task)
                                .position(x: geometry.size.width / 2, y: task.offset + (task.height / 2))
                        }
                    }
                }
                .frame(height: CGFloat(24) * Constants.hourRowHeight)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.navigationTitle)
    }
}

// MARK: - Task View

private struct TaskView: View {
    let dailyTask: DailyTask
    
    var body: some View {
        HStack {
            Text(dailyTask.task.title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Constants.timeColumnWidth)
        }
        .frame(height: dailyTask.height)
        .background(Color.accentColor.opacity(0.2))
    }
}
