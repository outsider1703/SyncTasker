//
//  DayFreeTimeCell.swift
//  SyncTasker
//
//  Created by ingvar on 06.05.2025.
//

import SwiftUI

struct DayFreeTimeCell: View {
    
    // MARK: - Initial Private Properties
    
    private let dayItem: FreeTimeDay
    
    // MARK: - Initialization
    
    init(
        dayItem: FreeTimeDay
    ) {
        self.dayItem = dayItem
    }
    
    // MARK: - Body
    
    var body: some View {
        if let date = dayItem.date {
            //            let isCurrentDate = Calendar.current.isDate(date, inSameDayAs: Date())
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.clear)
                
                VStack(spacing: 2) {
                    Text(date.toString(format: "d"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 11))
                        .padding([.top, .trailing], 2)
                    
                    if let freeTimes = dayItem.freeTimes {
                        ForEach(freeTimes, id: \.start) { start, end in
                            ZStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.green)
                                HStack(spacing: 0) {
                                    timeFromater(start)
                                    timeFromater(end)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 94)
            
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 94)
        }
    }
    
    private func timeFromater(_ time: String) -> some View {
        let timeComponents = time.components(separatedBy: ":")
        let hour = timeComponents.first ?? ""
        let minute = timeComponents.last ?? ""
        
        return HStack(spacing: 0) {
            Text(hour)
                .font(.system(size: 9))
            
            VStack(spacing: 0) {
                Text(minute)
                    .font(.system(size: 8))
                Divider()
            }
            .offset(y: -3)
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
