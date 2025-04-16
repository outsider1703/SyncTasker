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
    
    // MARK: - Initial Private Properties

    private let statistics: TaskStatistics
    
    // MARK: - Private Properties
    
    @State private var isAnimating = false
    @State private var animatedTotal: Int = 0
    @State private var timer: Timer? = nil
    
    // MARK: - Initialization
    
    init(
        statistics: TaskStatistics
    ) {
        self.statistics = statistics
    }
    
    var body: some View {
        VStack(spacing: Theme.Layout.spacing) {
            HStack(spacing: Theme.Layout.spacing) {
                StatCard(
                    title: Constants.totalTasks,
                    value: String(animatedTotal),
                    color: Theme.Colors.primary
                )
                .withFadeAnimation(isAnimating: isAnimating)
                CompletionProgressView(completionRate: statistics.completionRate, isAnimating: isAnimating)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            isAnimating = true
            startCountAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // Add counting animation function
    private func startCountAnimation() {
        timer?.invalidate()
        animatedTotal = 0
        
        let duration = 1.0 // Duration in seconds
        let stepTime = 0.05 // Time between increments
        let steps = Int(duration / stepTime)
        var currentStep = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            currentStep += 1
            let progress = Double(currentStep) / Double(steps)
            
            if progress >= 1.0 {
                animatedTotal = statistics.total
                timer.invalidate()
            } else {
                animatedTotal = Int(Double(statistics.total) * progress)
            }
        }
    }
}

private struct StatCard: View {
    
    // MARK: - Private Properties
    
    private let title: String
    private let value: String
    private let color: Color
    
    // MARK: - Initialization
    
    init(
        title: String,
        value: String,
        color: Color
    ) {
        self.title = title
        self.value = value
        self.color = color
    }
    
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
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

private struct CompletionProgressView: View {
    
    // MARK: - Private Properties
    
    private let completionRate: Double
    private let isAnimating: Bool
    
    // MARK: - Initialization
    
    init(
        completionRate: Double,
        isAnimating: Bool
    ) {
        self.completionRate = completionRate
        self.isAnimating = isAnimating
    }
    
    // MARK: - Body

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
