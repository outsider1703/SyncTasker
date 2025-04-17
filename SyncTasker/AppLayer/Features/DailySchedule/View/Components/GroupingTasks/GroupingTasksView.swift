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
    
    // MARK: - Initialization
    
    init(
        dailyTasks: [CGFloat: [DailyTask]],
        geometry: GeometryProxy,
        onTaskTap: @escaping (TaskItem) -> Void
    ) {
        self.dailyTasks = dailyTasks
        self.geometry = geometry
        self.onTaskTap = onTaskTap
    }
    
    // MARK: - Body
    
    var body: some View {
        let keys = Array(dailyTasks.keys)
        ForEach(keys, id: \.self) { offset in
            if let tasks = dailyTasks[offset] {
                HStack(spacing: 4) {
                    ForEach(tasks, id: \.task.id) { dailyTask in
                        DailyScheduleTaskView(dailyTask: dailyTask)
                            .onTapGesture { onTaskTap(dailyTask.task) }
                    }
                }
                .frame(maxWidth: .infinity)
                .position(x: geometry.size.width / 2, y: offset + (tasks[0].height / 2))
            }
        }
    }
}
