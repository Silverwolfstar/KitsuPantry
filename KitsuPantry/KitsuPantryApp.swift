//
//  KitsuPantryApp.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI
import CoreData

@main
struct KitsuPantryApp: App {
    let persistenceController = PersistenceController(inMemory: true) //.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
