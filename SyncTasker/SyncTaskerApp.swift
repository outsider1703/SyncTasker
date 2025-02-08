//
//  SyncTaskerApp.swift
//  SyncTasker
//
//  Created by ingvar on 08.02.2025.
//

import SwiftUI

@main
struct SyncTaskerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
