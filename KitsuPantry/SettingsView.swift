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
                Form {
                    Section(header: Text("Visual Options").foregroundColor(AppColor.sectionTitle)) {
                        Toggle("Highlight Expired Items", isOn: $highlightExpired)
                        Toggle("Highlight Expiring Soon Items", isOn: $highlightExpiringSoon)
                        Toggle("Show Obtained Date Field", isOn: $showObtainedDate)
                    }
                    
                    Section(header: Text("Behavior").foregroundColor(AppColor.sectionTitle)) {
                        Toggle("Suppress Duplicate Item Popups", isOn: $suppressDuplicatePopups)
                    }
                    
                    Section(header: Text("Tabs & Locations").foregroundColor(AppColor.sectionTitle)) {
                        Button("Manage Tabs") {
                            isManagingLocations = true
                        }
                    }
                    
                    Section(header: Text("Themes & UI").foregroundColor(AppColor.sectionTitle)) {
                        Text("Coming soon: theme customization 🦊")
                            .foregroundColor(AppColor.secondaryText)
                    }
                }
                .scrollContentBackground(.hidden)
//                .listRowSeparator(.hidden)
//                .listSectionSeparator(.hidden)
                
                .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $isManagingLocations) {
                    ManageLocationsView()
                }
            }
            .appBackground()
        }
    }
}
