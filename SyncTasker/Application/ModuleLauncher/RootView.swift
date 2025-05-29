//
//  RootView.swift
//  SyncTasker
//
//  Created by ingvar on 14.02.2025.
//

import SwiftUI

//RootView: настройка навигационного стека и создание views.

struct RootView: View {
    @StateObject private var navigationService: NavigationService
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
        _navigationService = StateObject(wrappedValue: container.navigationService)
    }
    
    var body: some View {
        NavigationStack(path: $navigationService.path) {
            CalendarView(viewModel: container.makeCalendarViewModel())
                .navigationDestination(for: Route.self) { route in
                    if !route.isModal {
                        makeView(for: route)
                    }
                }
                .sheet(item: $navigationService.presentedModal) { route in
                    makeView(for: route)
                        .presentationDetents([.medium, .large])
                }
        }
    }
    
    @ViewBuilder
    private func makeView(for route: Route) -> some View {
        switch route {
        case .taskDetail(let task):
            TaskDetailView(viewModel: container.makeTaskDetailViewModel(task: task))
        case .calendar:
            CalendarView(viewModel: container.makeCalendarViewModel())
        case .daily(let dayItem):
            DailyView(viewModel: container.makeDailyViewModel(dayItem: dayItem))
        case .freeTime(let daysInYear):
            FreeTimeView(viewModel: container.makeFreeTimeViewModel(months: daysInYear))
        case .sleepInstructaions:
            SleepInstructaionsView(viewModel: container.makeSleepInstructionsViewModel())
        }
    }
}
