//
//  TaskDatesSection.swift
//  SyncTasker
//
//  Created by ingvar on 10.03.2025.
//

import SwiftUI

private enum Constants {
    static let allDayTitle = "Весь день"
    static let startDateTitle = "Начало"
    static let endDateTitle = "Конец"
    static let travelTimeTitle = "Время в пути"
}

enum ActivePicker {
    case none
    case startDate
    case startTime
    case endDate
    case endTime
    case travelTime
}

struct TaskDatesSection: View {
    
    // MARK: - Private Properties
    
    @State private var activePicker: ActivePicker = .none
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    @Binding private var isAllDay: Bool
    @Binding private var travelTime: TravelTime
    
    // MARK: - Initialization
    
    init(
        startDate: Binding<Date>,
        endDate: Binding<Date>,
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
                title: Constants.startDateTitle,
                date: $startDate,
                isAllDay: isAllDay,
                activePicker: $activePicker,
                pickerType: (.startDate, .startTime),
                onDateChange: handleStartDateChange
            )
            
            DateSection(
                title: Constants.endDateTitle,
                date: $endDate,
                isAllDay: isAllDay,
                activePicker: $activePicker,
                pickerType: (.endDate, .endTime),
                dateRange: startDate...,
                timeRange: Calendar.current.isDate(startDate, inSameDayAs: endDate) ? startDate... : Date.distantPast...
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
    
    private func handleStartDateChange(_ newDate: Date) {
        // Если дата начала становится позже даты окончания - корректируем
        if Calendar.current.compare(newDate, to: endDate, toGranularity: .day) == .orderedDescending {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: newDate)
            let endComponents = calendar.dateComponents([.hour, .minute], from: endDate)
            
            var newEndComponents = components
            newEndComponents.hour = endComponents.hour
            newEndComponents.minute = endComponents.minute
            
            if let newEndDate = calendar.date(from: newEndComponents) { endDate = newEndDate }
        }
    }
}
