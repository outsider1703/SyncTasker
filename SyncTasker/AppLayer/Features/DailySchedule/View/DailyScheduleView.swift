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
        }
        .frame(height: Constants.hourRowHeight)
    }
}
