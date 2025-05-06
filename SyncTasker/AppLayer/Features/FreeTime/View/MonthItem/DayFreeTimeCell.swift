//
//  DayFreeTimeCell.swift
//  SyncTasker
//
//  Created by ingvar on 06.05.2025.
//

import SwiftUI

struct DayFreeTimeCell: View {
    
    // MARK: - Initial Private Properties
    
    private let dayItem: DayItem
    
    // MARK: - Initialization
    
    init(
        dayItem: DayItem
    ) {
        self.dayItem = dayItem
    }
    
    // MARK: - Body
    
    var body: some View {
        if let date = dayItem.date {
            let isCurrentDate = Calendar.current.isDate(date, inSameDayAs: Date())
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrentDate ? Theme.Colors.primary.opacity(0.2) : Color.clear)
                .frame(height: 64)
                .border(.black)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 64)
        }
    }
}

#if DEBUG
struct DayFreeTimeCell_Previews: PreviewProvider {
    static var previews: some View {
        let initialRouteForFreeTime = Route.freeTime([[]])
        let previewContainer = DIContainer(initialRoute: initialRouteForFreeTime)
        RootView(container: previewContainer)
    }
}
#endif
