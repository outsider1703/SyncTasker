//
//  SyncTaskerApp.swift
//  SyncTasker
//
//  Created by ingvar on 08.02.2025.
//

import SwiftUI

@main
struct SyncTaskerApp: App {
    // MARK: - Properties
    private let container = DIContainer.shared
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: container.makeTaskListViewModel(), container: container)
                .environment(\.managedObjectContext, container.coreDataService.viewContext)
        }
    }
}
