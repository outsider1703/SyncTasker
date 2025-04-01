//
//  TaskDatesSection.swift
//  SyncTasker
//
//  Created by ingvar on 10.03.2025.
//

import SwiftUI

private enum Constants {
    static let allDayTitle = "Весь день"
    static let travelTimeTitle = "Время в пути"
}

enum ActivePicker {
    case none
    case date
    case startTime
    case endTime
    case travelTime
}

struct TaskDatesSection: View {
    
    // MARK: - Private Properties
    
    @State private var activePicker: ActivePicker = .none
    @Binding private var startDate: Date?
    @Binding private var endDate: Date?
    @Binding private var isAllDay: Bool
    @Binding private var travelTime: TravelTime
    
    // MARK: - Initialization
    
    init(
        startDate: Binding<Date?>,
        endDate: Binding<Date?>,
        isAllDay: Binding<Bool>,
        travelTime: Binding<TravelTime>
    ) {
        self._startDate = startDate
        self._endDate = endDate
        self._isAllDay = isAllDay
        self._travelTime = travelTime
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Toggle(Constants.allDayTitle, isOn: $isAllDay)
                .onChange(of: isAllDay) { oldValue, newValue in
                    if newValue { withAnimation(.easeInOut(duration: 0.3)) { activePicker = .none } }
                }
            
            DateSection(
                startDate: $startDate,
                endDate: $endDate,
                isAllDay: isAllDay,
                activePicker: $activePicker
            )
            
            if !isAllDay {
                CustomPicker(Constants.travelTimeTitle, selection: $travelTime) {
                    ForEach(TravelTime.allCases, id: \.self) { time in
                        Label(time.title, systemImage: "clock")
                            .tag(time)
                    }
                }
            }
        }
    }
}
