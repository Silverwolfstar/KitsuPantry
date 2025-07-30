//
//  SettingsView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var categories: [CategoryEntity]
    @AppStorage("highlightExpired") private var highlightExpired = true
    @AppStorage("highlightExpiringSoon") private var highlightExpiringSoon = true
    @AppStorage("suppressDuplicatePopups") private var suppressDuplicatePopups = false
    @AppStorage("defaultQuantity") private var defaultQuantity = 1

    var body: some View {
        Form {
            Section(header: Text("Visual Options")) {
                Toggle("Highlight Expired Items", isOn: $highlightExpired)
                Toggle("Highlight Expiring Soon Items", isOn: $highlightExpiringSoon)
            }

            Section(header: Text("Behavior")) {
                Toggle("Suppress Duplicate Item Popups", isOn: $suppressDuplicatePopups)
//                Stepper("Default Quantity: \(defaultQuantity)", value: $defaultQuantity, in: 1...100)
            }

            Section(header: Text("Tabs & Categories")) {
                NavigationLink("Manage Tabs") {
                    ManageCategoriesView(categories: $categories)
                }
            }
            
            Section(header: Text("Themes & UI")) {
                Text("Coming soon: theme customization 🦊")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Settings")
    }
}
