//
//  TaskManagementCoreDataApp.swift
//  TaskManagementCoreData
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

@main
struct TaskManagementCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
