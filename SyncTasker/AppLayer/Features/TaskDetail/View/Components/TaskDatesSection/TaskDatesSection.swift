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

struct TaskDatesSection: View {
    
    // MARK: - Initial Private Properties
    
    @Binding private var startDate: Date?
    @Binding private var endDate: Date?
    @Binding private var isAllDay: Bool
    @Binding private var travelTime: TravelTime
    
    // MARK: - Private Properties
    
    @State private var activePicker: ActivePicker = .none

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
                activePicker: $activePicker,
                startDate: $startDate,
                endDate: $endDate,
                isAllDay: isAllDay
            )
            
            if !isAllDay {
                CustomPicker(selection: $travelTime, Constants.travelTimeTitle) {
                    ForEach(TravelTime.allCases, id: \.self) { time in
                        Label(time.title, systemImage: "clock")
                            .tag(time)
                    }
                }
            }
        }
    }
}
