//
//  DailyTaskView.swift
//  SyncTasker
//
//  Created by ingvar on 04.04.2025.
//

import SwiftUI

struct DailyTaskView: View {
    
    // MARK: - Initial Private Properties
    
    private let dailyTask: DailyTask
    private let onTap: (TaskItem) -> Void
    
    // MARK: - Initialization
    
    init(
        dailyTask: DailyTask,
        onTap: @escaping (TaskItem) -> Void
    ) {
        self.dailyTask = dailyTask
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text(dailyTask.task.title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
            Spacer()
        }
        .frame(height: dailyTask.height)
        .background(Color.accentColor.opacity(0.2))
        .onTapGesture { onTap(dailyTask.task) }
    }
}
