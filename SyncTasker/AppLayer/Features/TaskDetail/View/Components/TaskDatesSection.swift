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
        Section {
            // Toggle для "Весь день"
            Toggle(Constants.allDayTitle, isOn: $isAllDay)
                .onChange(of: isAllDay) { oldValue, newValue in
                    if newValue {
                        // При включении режима "весь день" закрываем все пикеры
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activePicker = .none
                        }
                    }
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
            
            // Время в пути (только если не весь день)
            if !isAllDay {
                Picker(Constants.travelTimeTitle, selection: $travelTime) {
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
            
            if let newEndDate = calendar.date(from: newEndComponents) {
                endDate = newEndDate
            }
        }
    }
}

struct DateSection: View {
    
    // MARK: - Private Properties
    
    @Binding private var activePicker: ActivePicker
    @Binding private var date: Date
    private let pickerType: (date: ActivePicker, time: ActivePicker)
    private let dateRange: PartialRangeFrom<Date>?
    private let timeRange: PartialRangeFrom<Date>?
    private let onDateChange: ((Date) -> Void)?
    private let isAllDay: Bool
    private let title: String
    
    private enum DateFormat {
        case date
        case time
    }
    
    // MARK: - Initialization
    
    init(
        title: String,
        date: Binding<Date>,
        isAllDay: Bool,
        activePicker: Binding<ActivePicker>,
        pickerType: (date: ActivePicker, time: ActivePicker),
        onDateChange: ((Date) -> Void)? = nil,
        dateRange: PartialRangeFrom<Date>? = nil,
        timeRange: PartialRangeFrom<Date>? = nil
    ) {
        self.title = title
        self._date = date
        self.isAllDay = isAllDay
        self._activePicker = activePicker
        self.pickerType = pickerType
        self.onDateChange = onDateChange
        self.dateRange = dateRange
        self.timeRange = timeRange
    }
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(title)
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
                
                customButton(date: date, icon: "calendar", format: .date, pickerType: pickerType.date, isActive: activePicker == pickerType.date)
                
                if !isAllDay {
                    customButton(date: date, icon: "clock", format: .time, pickerType: pickerType.time, isActive: activePicker == pickerType.time)
                }
            }
            
            VStack {
                if activePicker == pickerType.date {
                    DatePicker("", selection: $date, in: dateRange ?? Date()..., displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: date) { oldValue, newValue in
                            onDateChange?(newValue)
                        }
                } else if activePicker == pickerType.time && !isAllDay {
                    DatePicker("", selection: $date, in: timeRange ?? Date()..., displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxHeight: 150)
                }
            }
            .clipped()
            .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
        }
        .padding(.vertical, 4)
        .animation(.spring(duration: 0.3, bounce: 0.2), value: activePicker)
    }
    
    private func customButton(date: Date, icon: String, format: DateFormat, pickerType: ActivePicker, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                if activePicker == pickerType {
                    activePicker = .none
                } else {
                    activePicker = pickerType
                }
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                Text(
                    format == .date
                    ? date.formatted(date: .abbreviated, time: .omitted)
                    : date.formatted(date: .omitted, time: .shortened)
                )
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
