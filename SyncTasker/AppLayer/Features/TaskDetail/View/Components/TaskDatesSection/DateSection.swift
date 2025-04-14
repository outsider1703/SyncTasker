//
//  DateSection.swift
//  SyncTasker
//
//  Created by ingvar on 13.03.2025.
//

import SwiftUI

struct DateSection: View {
    
    // MARK: - Private Properties
    
    @Binding private var activePicker: ActivePicker
    @Binding private var startDate: Date?
    @Binding private var endDate: Date?
    private let isAllDay: Bool
    
    private enum DateFormat {
        case date
        case time
    }
    
    // MARK: - Initialization
    
    init(
        startDate: Binding<Date?>,
        endDate: Binding<Date?>,
        isAllDay: Bool,
        activePicker: Binding<ActivePicker>
    ) {
        self._startDate = startDate
        self._endDate = endDate
        self.isAllDay = isAllDay
        self._activePicker = activePicker
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("Время")
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
                
                customButton(date: startDate, icon: "calendar", format: .date, pickerType: .date, isActive: activePicker == .date)
                if !isAllDay {
                    customButton(date: startDate, icon: "clock", format: .time, pickerType: .startTime, isActive: activePicker == .startTime)
                    customButton(date: endDate, icon: "clock", format: .time, pickerType: .endTime, isActive: activePicker == .endTime)
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
    
    // MARK: - Subviews

    private func customButton(date: Date?, icon: String, format: DateFormat, pickerType: ActivePicker, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) { activePicker = activePicker == pickerType ? .none : pickerType }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                let title = format == .date ? date?.formatted(date: .abbreviated, time: .omitted) ?? "date" : date?.formatted(date: .omitted, time: .shortened) ?? "time"
                Text(title)
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray6))
            )
        }
    }
}
