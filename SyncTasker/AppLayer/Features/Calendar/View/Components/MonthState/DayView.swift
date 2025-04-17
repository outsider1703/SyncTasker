//
//  DayView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayView: View {
    
    // MARK: - Initial Private Properties
    
    private let date: Date?
    private let type: DayItemType?
    private var tasks: [TaskItem] = []
    private let onTaskDropped: (UUID, Date?) -> Void
    
    // MARK: - Initial Private Properties

    private var isDay: Bool { type == .day }
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem?,
        onTaskDropped: @escaping (UUID, Date?) -> Void
    ) {
        self.date = dayItem?.date
        self.type = dayItem?.type
        self.tasks = dayItem?.tasks ?? []
        self.onTaskDropped = onTaskDropped
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top) {
                if let dateTitle = date?.toString(format: isDay ? "dd" : "MMMM") {
                    Text(dateTitle)
                        .font(Theme.Typography.bodyFont)
                        .padding(8)
                }
                Spacer()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .frame(width: 150, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDay ? .white : .clear)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .foregroundColor(.black)
        .dropDestination(for: String.self) { items, _ in
            guard let taskId = UUID(uuidString: items.first ?? "") else { return false }
            onTaskDropped(taskId, date)
            return true
        }
    }
}
