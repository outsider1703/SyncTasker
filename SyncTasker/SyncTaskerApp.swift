//
//  SyncTaskerApp.swift
//  SyncTasker
//
//  Created by ingvar on 08.02.2025.
//

import SwiftUI

@main
struct SyncTaskerApp: App {

    let coreDataService = CoreDataService.shared
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, coreDataService.viewContext)
        }
    }
}
