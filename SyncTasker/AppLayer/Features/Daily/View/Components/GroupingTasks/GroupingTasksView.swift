//
//  GroupingTasksView.swift
//  SyncTasker
//
//  Created by ingvar on 17.04.2025.
//

import SwiftUI

struct GroupingTasksView: View {
    
    // MARK: - Initial Private Properties
    
    private let dailyTasks: [CGFloat: [DailyTask]]
    private let geometry: GeometryProxy
    private let onTaskTap: (TaskItem) -> Void
    private let onSleepTap: () -> Void
    
    // MARK: - Initialization
    
    init(
        dailyTasks: [CGFloat: [DailyTask]],
        geometry: GeometryProxy,
        onTaskTap: @escaping (TaskItem) -> Void,
        onSleepTap: @escaping () -> Void
    ) {
        self.dailyTasks = dailyTasks
        self.geometry = geometry
        self.onTaskTap = onTaskTap
        self.onSleepTap = onSleepTap
    }
    
    // MARK: - Body
    
    var body: some View {
        ForEach(Array(dailyTasks.keys), id: \.self) { offset in
            
            if let tasksByOffset = dailyTasks[offset] {
                let (sleep, tasks) = tasksByOffset.partitioned { $0.task.title == "sleep" }
                
                ForEach(sleep, id: \.task.id) { dailySleep in
                    DailySleepView(dailySleep: dailySleep, onTap: onSleepTap)
                        .position(x: geometry.size.width / 2, y: offset + (sleep[0].height / 2))
                }
                
                HStack(spacing: 4) {
                    ForEach(tasks, id: \.task.id) { dailyTask in
                        DailyTaskView(dailyTask: dailyTask, onTap: onTaskTap)
                    }
                }
                .position(x: geometry.size.width / 2, y: offset + (tasksByOffset[0].height / 2))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
