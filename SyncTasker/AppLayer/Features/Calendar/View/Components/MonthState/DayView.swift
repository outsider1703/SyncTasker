//
//  DayView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayView: View {
    
    // MARK: - Private Properties
    
    private var tasks: [TaskItem] = []
    private let date: Date
    private let onTap: () -> Void
    private let calendar = Calendar.current
    private let onTaskDropped: (UUID, Date) -> Void
    
    // MARK: - Initialization
    
    init(
        date: Date,
        tasks: [TaskItem],
        onTap: @escaping () -> Void,
        onTaskDropped: @escaping (UUID, Date) -> Void
    ) {
        self.date = date
        self.tasks = tasks
        self.onTap = onTap
        self.onTaskDropped = onTaskDropped
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                Text("\(calendar.component(.day, from: date))")
                    .font(Theme.Typography.bodyFont)
                    .padding(8)
            }
            .frame(width: 150, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .foregroundColor(.black)
        .onTapGesture(perform: onTap)
        .dropDestination(for: String.self) { items, _ in
            guard let taskId = UUID(uuidString: items.first ?? "") else { return false }
            onTaskDropped(taskId, date)
            return true
        }
    }
}
