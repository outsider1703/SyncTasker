//
//  DailyScheduleTaskView.swift
//  SyncTasker
//
//  Created by ingvar on 04.04.2025.
//

import SwiftUI

struct DailyScheduleTaskView: View {
    
    let dailyTask: DailyTask
    let didTouchTask: () -> Void
    
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
        .onTapGesture {
            didTouchTask()
        }
    }
}
