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
                        
                        // Задачи с группировкой
                        groupingTasks(with: geometry)
                    }
                }
                .frame(height: Constants.hourRowHeight * 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.navigationTitle)
    }
    
    func groupingTasks(with geometry: GeometryProxy) -> some View {
        let keys = Array(viewModel.dailyTasks.keys)
        return ForEach(keys, id: \.self) { offset in
            if let tasks = viewModel.dailyTasks[offset] {
                HStack(spacing: 4) {
                    ForEach(tasks, id: \.task.id) { dailyTask in
                        DailyScheduleTaskView(dailyTask: dailyTask) { viewModel.navigateToTaskDetail(dailyTask.task) }
                    }
                }
                .frame(maxWidth: .infinity)
                .position(x: geometry.size.width / 2, y: offset + (tasks[0].height / 2))
            }
        }
    }
}
