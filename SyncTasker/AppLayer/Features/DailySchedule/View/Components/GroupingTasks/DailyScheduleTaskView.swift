//
//  DailyScheduleTaskView.swift
//  SyncTasker
//
//  Created by ingvar on 04.04.2025.
//

import SwiftUI

struct DailyScheduleTaskView: View {
    
    // MARK: - Initial Private Properties

    private let dailyTask: DailyTask
    
    // MARK: - Initialization

    init(
        dailyTask: DailyTask
    ) {
        self.dailyTask = dailyTask
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
    }
}
