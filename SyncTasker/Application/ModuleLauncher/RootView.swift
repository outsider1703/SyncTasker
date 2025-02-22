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
                    makeView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func makeView(for route: Route) -> some View {
        switch route {
        case .taskList:
            TaskListView(viewModel: container.makeTaskListViewModel())
        case .taskDetail(let task):
            TaskDetailView(viewModel: container.makeTaskDetailViewModel(task: task))
        case .calendar:
            CalendarView(viewModel: container.makeCalendarViewModel())
        }
    }
}
