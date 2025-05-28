//
//  DayView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayView: View {
    
    // MARK: - Initial Private Properties
    
    private let dayItem: DayItem
    private let onTaskDropped: (UUID, Date?) -> Void
    private let onDayDetail: (DayItem) -> Void
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem,
        onTaskDropped: @escaping (UUID, Date?) -> Void,
        onDayDetail: @escaping (DayItem) -> Void
    ) {
        self.dayItem = dayItem
        self.onTaskDropped = onTaskDropped
        self.onDayDetail = onDayDetail
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if let dateTitle = dayItem.date?.toString(format: "d MM YY") {
                Text(dateTitle)
                    .font(Theme.Typography.bodyFont)
                    .padding(8)
            }
            Spacer()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(dayItem.tasks) { task in
                        TaskRowView(task: task)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .border(.black, width: 1)
        .onTapGesture { onDayDetail(dayItem) }
        .dropDestination(for: String.self) { items, _ in
            guard let taskId = UUID(uuidString: items.first ?? "") else { return false }
            onTaskDropped(taskId, dayItem.date)
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
