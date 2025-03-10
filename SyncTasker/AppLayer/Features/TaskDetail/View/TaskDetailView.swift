//
//  TaskDetailView.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import SwiftUI

private enum Constants {
    static let createTitle = "Create Task"
    static let editTitle = "Edit Task"
    static let titlePlaceholder = "Task Title"
    static let descriptionPlaceholder = "Task Description"
    static let dueDateTitle = "Due Date"
    static let appointmentDateTitle = "Appointment Date"
    static let priorityTitle = "Priority"
    static let repeatTitle = "Repeat"
    static let reminderTitle = "Reminder"
    static let isCompletedTitle = "Completed"
    static let saveButton = "Save"
    static let cancelButton = "Cancel"
    static let errorTitle = "Error"
    static let okButton = "OK"
    static let startDateTitle = "Начало"
    static let endDateTitle = "Конец"
    static let allDayTitle = "Весь день"
    static let travelTimeTitle = "Время в пути"
    static let dateTitle = "Дата"
    static let timeTitle = "Время"
    static let selectDate = "Выбрать дату"
    static let selectTime = "Выбрать время"
}

struct TaskDetailView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: TaskDetailViewModel
    
    // MARK: - Initialization
    
    init(
        viewModel: TaskDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                TaskTitleSection(title: $viewModel.title, description: $viewModel.taskDescription)
                TaskDatesSection(
                    startDate: $viewModel.startDate,
                    endDate: $viewModel.endDate,
                    isAllDay: $viewModel.isAllDay,
                    travelTime: $viewModel.travelTime
                )
                TaskPropertiesSection(
                    priority: $viewModel.priority,
                    repetition: $viewModel.repetition,
                    reminder: $viewModel.reminder,
                    isCompleted: $viewModel.isCompleted,
                    isEditMode: viewModel.isEditMode
                )
            }
            .navigationTitle(viewModel.isEditMode ? Constants.editTitle : Constants.createTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Constants.cancelButton) {
                        Task { await viewModel.dismiss() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.saveButton) {
                        Task { await viewModel.createOrEditTask() }
                    }
                }
            }
            .alert(Constants.errorTitle, isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) { Button(Constants.okButton) { viewModel.errorMessage = nil } }
            message: { Text(viewModel.errorMessage ?? "") }
        }
    }
}

// MARK: - Title Section View

struct TaskTitleSection: View {
    
    @Binding var title: String
    @Binding var description: String
    
    init(
        title: Binding<String>,
        description: Binding<String>
    ) {
        self._title = title
        self._description = description
    }
    
    var body: some View {
        Section {
            TextField(Constants.titlePlaceholder, text: $title)
                .font(Theme.Typography.headlineFont)
            
            TextEditor(text: $description)
                .font(Theme.Typography.bodyFont)
                .frame(minHeight: 40)
                .placeholder(when: description.isEmpty) {
                    Text(Constants.descriptionPlaceholder)
                        .foregroundColor(Theme.Colors.secondary)
                }
        }
    }
}

// MARK: - Dates Section View

struct TaskDatesSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isAllDay: Bool
    @Binding var travelTime: TravelTime
    
    private enum ActivePicker {
        case none
        case startDate
        case startTime
        case endDate
        case endTime
        case travelTime
    }
    
    @State private var activePicker: ActivePicker = .none
    
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
            
            // Секция начала
            startDateSection
            
            // Секция конца
            endDateSection
            
            // Время в пути (только если не весь день)
            if !isAllDay {
                travelTimeSection
            }
        }
    }
    
    private var startDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(Constants.startDateTitle)
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)

                // Кнопка выбора даты
                dateButton(date: startDate, onTap: { togglePicker(.startDate) })
                
                // Кнопка выбора времени (если не весь день)
                if !isAllDay {
                    timeButton(date: startDate, onTap: { togglePicker(.startTime) })
                }
            }
            
            // Пикер даты
            if activePicker == .startDate {
                DatePicker("", selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: startDate) { oldValue, newValue in
                        handleStartDateChange(newValue)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
            
            // Пикер времени
            if activePicker == .startTime && !isAllDay {
                DatePicker("", selection: $startDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxHeight: 150)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .padding(.vertical, 4)
    }
    
    private var endDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(Constants.endDateTitle)
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)

                // Кнопка выбора даты
                dateButton(date: endDate, onTap: { togglePicker(.endDate) })
                
                // Кнопка выбора времени (если не весь день)
                if !isAllDay {
                    timeButton(date: endDate, onTap: { togglePicker(.endTime) })
                }
            }
            
            // Пикер даты
            if activePicker == .endDate {
                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
            
            // Пикер времени
            if activePicker == .endTime && !isAllDay {
                let range = Calendar.current.isDate(startDate, inSameDayAs: endDate) ? startDate... : Date.distantPast...
                DatePicker("", selection: $endDate, in: range, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxHeight: 150)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func togglePicker(_ picker: ActivePicker) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activePicker = activePicker == picker ? .none : picker
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
    
    // Кнопка выбора даты
    private func dateButton(date: Date, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // Кнопка выбора времени
    private func timeButton(date: Date, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(Theme.Typography.bodyFont)
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // Секция времени в пути
    private var travelTimeSection: some View {
        VStack {
            Picker(Constants.travelTimeTitle, selection: $travelTime) {
                ForEach(TravelTime.allCases, id: \.self) { time in
                    Label(time.title, systemImage: "clock")
                        .tag(time)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Properties Section View

struct TaskPropertiesSection: View {
    
    @Binding var priority: TaskItem.Priority
    @Binding var repetition: TaskItem.Repetition
    @Binding var reminder: TaskItem.Reminder
    @Binding var isCompleted: Bool
    let isEditMode: Bool
    
    init(
        priority: Binding<TaskItem.Priority>,
        repetition: Binding<TaskItem.Repetition>,
        reminder: Binding<TaskItem.Reminder>,
        isCompleted: Binding<Bool>,
        isEditMode: Bool
    ) {
        self._priority = priority
        self._repetition = repetition
        self._reminder = reminder
        self._isCompleted = isCompleted
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        Section {
            VStack {
                Picker(Constants.priorityTitle, selection: $priority) {
                    ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                        Label(priority.title, systemImage: priority.icon)
                            .tag(priority)
                    }
                }
                
                Picker(Constants.repeatTitle, selection: $repetition) {
                    ForEach(TaskItem.Repetition.allCases, id: \.self) { repetition in
                        Label(repetition.rawValue, systemImage: "repeat")
                            .tag(repetition)
                    }
                }
                
                Picker(Constants.reminderTitle, selection: $reminder) {
                    ForEach(TaskItem.Reminder.allCases, id: \.self) { reminder in
                        Label(reminder.rawValue, systemImage: "clock")
                            .tag(reminder)
                    }
                }
                
                if isEditMode {
                    Toggle(Constants.isCompletedTitle, isOn: $isCompleted)
                }
            }
        }
    }
}
