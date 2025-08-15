//
//  SettingsView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("highlightExpired") private var highlightExpired = true
    @AppStorage("highlightExpiringSoon") private var highlightExpiringSoon = true
    @AppStorage("suppressDuplicatePopups") private var suppressDuplicatePopups = false
    @AppStorage("defaultQuantity") private var defaultQuantity = 1
    @AppStorage("showObtainedDate") private var showObtainedDate = true
    
    @State private var isManagingTabs = false
    @State private var isManagingLocations = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.72, green: 0.78, blue: 0.89)
                    .ignoresSafeArea()
                Form {
                    Section(header: Text("Visual Options").foregroundColor(.black)) {
                        Toggle("Highlight Expired Items", isOn: $highlightExpired)
                        Toggle("Highlight Expiring Soon Items", isOn: $highlightExpiringSoon)
                        Toggle("Show Obtained Date Field", isOn: $showObtainedDate)
                    }
                    
                    Section(header: Text("Behavior").foregroundColor(.black)) {
                        Toggle("Suppress Duplicate Item Popups", isOn: $suppressDuplicatePopups)
                    }
                    
                    Section(header: Text("Tabs & Locations").foregroundColor(.black)) {
                        Button("Manage Tabs") {
                            isManagingLocations = true
                        }
                    }
                    
                    Section(header: Text("Themes & UI")) {
                        Text("Coming soon: theme customization 🦊")
                            .foregroundColor(.gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $isManagingLocations) {
                    ManageLocationsView()
                }
            }
        }
    }
}
