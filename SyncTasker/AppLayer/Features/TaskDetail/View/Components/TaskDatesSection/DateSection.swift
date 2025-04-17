//
//  DateSection.swift
//  SyncTasker
//
//  Created by ingvar on 13.03.2025.
//

import SwiftUI

struct DateSection: View {
    
    // MARK: - Initial Private Properties
    
    @Binding private var activePicker: ActivePicker
    @Binding private var startDate: Date?
    @Binding private var endDate: Date?
    private let isAllDay: Bool
    
    // MARK: - Initialization
    
    init(
        activePicker: Binding<ActivePicker>,
        startDate: Binding<Date?>,
        endDate: Binding<Date?>,
        isAllDay: Bool
    ) {
        self._activePicker = activePicker
        self._startDate = startDate
        self._endDate = endDate
        self.isAllDay = isAllDay
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("Время")
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
                
                CustomDateButton(
                    date: startDate,
                    icon: "calendar",
                    format: .date,
                    isActive: activePicker == .date,
                    pickerType: .date,
                    activePicker: $activePicker
                )
                if !isAllDay {
                    CustomDateButton(
                        date: startDate,
                        icon: "clock",
                        format: .time,
                        isActive: activePicker == .startTime,
                        pickerType: .startTime,
                        activePicker: $activePicker
                    )
                    CustomDateButton(
                        date: endDate,
                        icon: "clock",
                        format: .time,
                        isActive: activePicker == .endTime,
                        pickerType: .endTime,
                        activePicker: $activePicker
                    )
                }
            }
            
            VStack {
                if activePicker == .date {
                    DatePicker("",
                               selection: Binding<Date>(get: { self.startDate ?? Date() }, set: { self.startDate = $0 }),
                               in: Date()...,
                               displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                } else if (activePicker == .startTime || activePicker == .endTime) && !isAllDay {
                    DatePicker("",
                               selection: Binding<Date>(
                                get: { (activePicker == .startTime ? startDate : endDate) ?? Date() },
                                set: { activePicker == .startTime ? (startDate = $0) : (endDate = $0) }
                               ),
                               in: activePicker == .endTime ? (startDate ?? Date())... : Date.distantPast...,
                               displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: startDate ?? Date()) { oldValue, newValue in
                        //Если время начала становится позже времени окончания - корректируем
                        if Calendar.current.compare(newValue, to: endDate ?? Date(), toGranularity: .minute) == .orderedDescending {
                            endDate = newValue.addingTimeInterval(3600)
                        }
                    }
                }
            }
            .clipped()
            .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
        }
        .padding(.vertical, 4)
        .animation(.spring(duration: 0.3, bounce: 0.2), value: activePicker)
    }
}
