//
//  ContentView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            ItemsListView(filter: .all, title: "All")
                .tabItem {
                    Label("All", systemImage: "tray.full")
                }

            ItemsListView(filter: .location("Fridge"), title: "Fridge")
                .tabItem {
                    Label("Fridge", systemImage: "snowflake")
                }

            ItemsListView(filter: .location("Freezer"), title: "Freezer")
                .tabItem {
                    Label("Freezer", systemImage: "drop")
                }

            ItemsListView(filter: .location("Pantry"), title: "Pantry")
                .tabItem {
                    Label("Pantry", systemImage: "archivebox")
                }
        }
        .onAppear {
            seedDefaultCategories(context: viewContext)
        }
    }
}
