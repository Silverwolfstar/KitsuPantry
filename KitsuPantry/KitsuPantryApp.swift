//
//  KitsuPantryApp.swift
//  KitsuPantry
//
//  Created by Silver WolfStar on 7/17/25.
//

import SwiftUI

@main
struct KitsuPantryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
