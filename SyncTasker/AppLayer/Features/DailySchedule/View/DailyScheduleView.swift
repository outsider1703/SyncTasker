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
    static let timelineWidth: CGFloat = 2
    static let taskCornerRadius: CGFloat = 12
    static let timeIndicatorSize: CGFloat = 10
    static let taskCardPadding: CGFloat = 16
    static let hourRowHeight: CGFloat = 100
    static let headerSpacing: CGFloat = 20
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
            headerView
                .padding(.bottom)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.activeHours, id: \.self) { hour in
                        hourRowView(for: hour)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
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
    
    // MARK: - Hour Row View
    
    private func hourRowView(for hour: Int) -> some View {
        let tasks = viewModel.tasksByHour[hour] ?? []
        
        return HStack(alignment: .top, spacing: 16) {
            // Time column
            VStack(alignment: .trailing) {
                Text(viewModel.formattedTime(for: hour))
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .trailing)
                
                Spacer()
            }
            .frame(height: Constants.hourRowHeight)
            
            // Timeline
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: Constants.timeIndicatorSize, height: Constants.timeIndicatorSize)
                
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: Constants.timelineWidth)
                    .frame(maxHeight: .infinity)
            }
            
            // Tasks
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tasks, id: \.id) { task in
                    taskCardView(task)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if tasks.isEmpty {
                    Text("No tasks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Task Card View
    
    private func taskCardView(_ task: TaskItem) -> some View {
        let isSelected = selectedTask?.id == task.id
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            if let description = task.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(isSelected ? nil : 2)
            }
            
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 10, height: 10)
                
                Text(task.priority.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.markTaskCompleted(task)
                    }
                }) {
                    Text("Complete")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.2))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding(Constants.taskCardPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.taskCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            withAnimation {
                if selectedTask?.id == task.id {
                    selectedTask = nil
                } else {
                    selectedTask = task
                }
            }
        }
    }
}
