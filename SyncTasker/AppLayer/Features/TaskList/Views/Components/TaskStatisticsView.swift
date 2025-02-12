//
//  TaskStatisticsView.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import SwiftUI

private enum Constants {
    static let totalTasks = "Total Tasks"
    static let completed = "Completed"
    static let overdue = "Overdue"
    static let highPriority = "High Priority"
    static let completion = "Completion"
}

struct TaskStatisticsView: View {
    let statistics: TaskStatistics
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.Layout.spacing) {
            HStack(spacing: Theme.Layout.spacing) {
                StatCard(title: Constants.totalTasks, value: String(statistics.total), color: Theme.Colors.primary)
                    .withFadeAnimation(isAnimating: isAnimating)
                StatCard(title: Constants.completed, value: String(statistics.completed), color: Theme.Colors.success)
                    .withFadeAnimation(isAnimating: isAnimating)
            }
            
            HStack(spacing: Theme.Layout.spacing) {
                StatCard(title: Constants.overdue, value: String(statistics.overdue), color: Theme.Colors.error)
                    .withFadeAnimation(isAnimating: isAnimating)
                StatCard(title: Constants.highPriority, value: String(statistics.highPriority), color: Theme.Colors.accent)
                    .withFadeAnimation(isAnimating: isAnimating)
            }
            
            CompletionProgressView(completionRate: statistics.completionRate, isAnimating: isAnimating)
        }
        .padding()
        .background(Theme.Colors.background)
        .onAppear { isAnimating = true }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.Typography.captionFont)
                .foregroundColor(Theme.Colors.secondary)
            
            Text(value)
                .font(Theme.Typography.titleFont)
                .foregroundColor(color)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

private struct CompletionProgressView: View {
    let completionRate: Double
    let isAnimating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Constants.completion)
                .font(Theme.Typography.captionFont)
                .foregroundColor(Theme.Colors.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.Colors.secondary.opacity(0.2))
                    
                    Rectangle()
                        .fill(Theme.Colors.success)
                        .frame(width: isAnimating ? geometry.size.width * completionRate : 0)
                        .animation(.spring().delay(0.3), value: isAnimating)
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
            }
            .frame(height: 8)
            
            Text("\(Int(completionRate * 100))%")
                .font(Theme.Typography.headlineFont)
                .foregroundColor(Theme.Colors.success)
                .fontWeight(.bold)
        }
        .padding()
        .background(Theme.Colors.success.opacity(0.1))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.success.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
