//
//  CustomPicker.swift
//  SyncTasker
//
//  Created by ingvar on 13.03.2025.
//

import SwiftUI

struct CustomPicker<T: Hashable, Content: View>: View {
    
    // MARK: - Initial Private Properties

    @Binding private var selection: T
    private let title: String
    private let content: () -> Content
    
    // MARK: - Initialization

    init(
        selection: Binding<T>,
        _ title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.title = title
        self.content = content
    }
    
    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Picker(title, selection: $selection) {
                content()
            }
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

struct CustomDateButton: View {
    
    // MARK: - Initial Private Properties
    
    private let date: Date?
    private let icon: String
    private let format: DateFormat
    private let isActive: Bool
    private let pickerType: ActivePicker
    @Binding var activePicker: ActivePicker
    
    // MARK: - Initialization
    
    init(
        date: Date?,
        icon: String,
        format: DateFormat,
        isActive: Bool,
        pickerType: ActivePicker,
        activePicker: Binding<ActivePicker>
    ) {
        self.date = date
        self.icon = icon
        self.format = format
        self.isActive = isActive
        self.pickerType = pickerType
        self._activePicker = activePicker
    }
    
    // MARK: - Body

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                activePicker = activePicker == pickerType ? .none : pickerType
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                
                let title = format == .date ?
                date?.formatted(date: .abbreviated, time: .omitted) ?? "date" :
                date?.formatted(date: .omitted, time: .shortened) ?? "time"
                
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
