//
//  DailyScheduleView.swift
//  SyncTasker
//
//  Created by ingvar on 25.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let monthTitleScale: CGFloat = 1.2
    static let titleAnimationDuration: Double = 0.3
    static let timelineWidth: CGFloat = 1
    static let taskCornerRadius: CGFloat = 8
    static let timeIndicatorSize: CGFloat = 10
    static let taskCardPadding: CGFloat = 16
    static let hourRowHeight: CGFloat = 60
    static let headerSpacing: CGFloat = 20
    static let timeColumnWidth: CGFloat = 50
}

struct DailyScheduleView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: DailyScheduleViewModel
    
    // MARK: - Private Properties
    @State private var animateHeader = false
    @State private var selectedTask: TaskItem? = nil
    @Environment(\.colorScheme) var colorScheme
    
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
        .onAppear {
            withAnimation(.easeInOut(duration: Constants.titleAnimationDuration)) {
                animateHeader = true
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: Constants.headerSpacing) {
            Text(viewModel.dayOfWeek)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.formattedDate)
                .font(.largeTitle.bold())
                .scaleEffect(animateHeader ? Constants.monthTitleScale : 1.0)
        }
        .padding(.top)
        .frame(maxWidth: .infinity)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                .mask(Rectangle().padding(.bottom, -20))
        )
    }
    
    // MARK: - All Day Tasks Section
    
    private var allDayTasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("весь день")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.allDayTasks) { task in
                allDayTaskCard(task)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - All Day Task Card
    
    private func allDayTaskCard(_ task: TaskItem) -> some View {
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
    
    // MARK: - Hour Row View
    
    private func hourRowView(for hour: Int) -> some View {
        let tasks = viewModel.tasksByHour[hour] ?? []
        
        return HStack(spacing: 0) {
            // Time column
            Text(String(format: "%02d:00", hour))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: Constants.timeColumnWidth, alignment: .center)
            
            // Divider line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Tasks
            if !tasks.isEmpty {
                ForEach(tasks) { task in
                    taskCard(task)
                }
            }
        }
        .frame(height: Constants.hourRowHeight)
    }
    
    // MARK: - Task Card View
    
    private func taskCard(_ task: TaskItem) -> some View {
        Text(task.title)
            .font(.subheadline)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(Constants.taskCornerRadius)
            .padding(.horizontal, 8)
    }
}
