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
    @AppStorage("expiringSoonDays") private var expiringSoonDays = 3
    @AppStorage("showStatusBanner") private var showStatusBanner = true
    
    @State private var isManagingTabs = false
    @State private var isManagingLocations = false
    @State private var showingHelp = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Form {
                    Section(header: Text("Visual Options").foregroundColor(AppColor.sectionTitle)) {
                        FormRow {
                            Toggle("Highlight Expired Items", isOn: $highlightExpired)}
                        FormRow {
                            Toggle("Highlight Expiring Soon Items", isOn: $highlightExpiringSoon)}
                        FormRow(showSeparator: false) {
                            Toggle("Show Obtained Date Field", isOn: $showObtainedDate)}
                    }
                    
                    Section(header: Text("Expiring Soon Settings").foregroundColor(AppColor.sectionTitle)) {
                        FormRow {
                            Toggle("Show Expiring/Expired Banner", isOn: $showStatusBanner)
                        }
                        FormRow(showSeparator: false) {
                            Stepper(
                                "Expiring Soon: \(expiringSoonDays) Day\(expiringSoonDays == 1 ? "" : "s")",
                                value: $expiringSoonDays,
                                in: 1...30
                            )
                        }
                    }
                    
                    Section(header: Text("Behavior").foregroundColor(AppColor.sectionTitle)) {
                        FormRow(showSeparator: false) {
                            Toggle("Suppress Duplicate Item Popups", isOn: $suppressDuplicatePopups)}
                    }
                    
                    Section(header: Text("Tabs & Locations").foregroundColor(AppColor.sectionTitle)) {
                        FormRow(showSeparator: false) {
                            Button("Manage Locations") {
                                isManagingLocations = true}
                        }
                    }
                    
                    Section(header: Text("Themes & UI").foregroundColor(AppColor.sectionTitle)) {
                        FormRow(showSeparator: false) {
                            Text("Coming Soon: Theme Customization 🦊")
                                .foregroundColor(AppColor.secondaryText)
                        }
                    }
                }
                .appFormInsets(content: 16, line: 0)
                .scrollContentBackground(.hidden)
                .listSectionSpacing(0)
                .listRowSpacing(0)
                
                .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $isManagingLocations) {
                    ManageLocationsView()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        .accessibilityLabel("Help")
                        .foregroundColor(AppColor.navBarButtons)
                    }
                }
                .sheet(isPresented: $showingHelp) {
                    HelpView()
                }
            }
            .appBackground()
        }
    }
}
