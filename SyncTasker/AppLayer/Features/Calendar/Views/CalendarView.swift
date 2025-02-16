//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let navigationTitle = "Calendar"
    static let taskListButtonTitle = "Open Task List"
    static let taskListIcon = "list.bullet"
}

struct CalendarView: View {
    // MARK: - ViewModel
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Initialization
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            Button(action: { viewModel.navigateToTaskList() }) {
                Label(Constants.taskListButtonTitle, systemImage: Constants.taskListIcon)
                    .font(Theme.Typography.headlineFont)
                    .foregroundColor(Theme.Colors.primary)
                    .padding()
                    .background(Theme.Colors.background)
                    .cornerRadius(Theme.Layout.cornerRadius)
            }
        }
    }
}
