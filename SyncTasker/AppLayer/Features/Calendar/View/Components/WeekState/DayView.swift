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
    private var tasks: [TaskItem] = []
    private let onTaskDropped: (UUID, Date?) -> Void
    
    // MARK: - Private Properties
    
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem?,
        onTaskDropped: @escaping (UUID, Date?) -> Void
    ) {
        self.date = dayItem?.date
        self.tasks = dayItem?.tasks ?? []
        self.onTaskDropped = onTaskDropped
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if let dateTitle = date?.toString(format: "d MM YY") {
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
        .frame(maxWidth: .infinity)
        .border(.black, width: 1)
        .dropDestination(for: String.self) { items, _ in
            guard let taskId = UUID(uuidString: items.first ?? "") else { return false }
            onTaskDropped(taskId, date)
            return true
        }
    }
}

#if DEBUG
struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
