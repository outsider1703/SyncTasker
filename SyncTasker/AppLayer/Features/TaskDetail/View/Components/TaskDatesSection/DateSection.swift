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
