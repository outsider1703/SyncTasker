//
//  DayCell.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayCell: View {
    
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
                .frame(width: 16, height: 16)
                .border(.black)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 16, height: 16)
        }
    }
}

#if DEBUG
struct DayCell_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
