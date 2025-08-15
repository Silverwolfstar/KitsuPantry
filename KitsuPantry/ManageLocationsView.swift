//
//  ManageLocationsView.swift
//  KitsuPantry
//
//  Created by Silver on 7/30/25.
//

import SwiftUI
import CoreData

struct ManageLocationsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: LocationEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default
    ) private var locations: FetchedResults<LocationEntity>

    @State private var newLocationName: String = ""
    @State private var locationBeingRenamed: LocationEntity?
    @State private var editedName: String = ""
    @State private var renameConflictError = false
    
    private var isAddDisabled: Bool {
        let trimmed = newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ||
               trimmed.lowercased() == "all" ||
               locations.contains(where: { $0.name?.lowercased() == trimmed.lowercased() })
    }

    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }
    
    private var hasReachedTabLimit: Bool {
        locations.filter { $0.name != "All" }.count >= 5
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.72, green: 0.78, blue: 0.89)
                Form {
                    if !hasReachedTabLimit {
                        Section(header: Text("Add New Location").foregroundColor(.black)) {
                            TextField("New Location Name", text: $newLocationName)
                            
                            if !newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isAddDisabled {
                                Text("You cannot name a tab \"All\" or reuse an existing name.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: handleAddLocation) {
                                Text("Add")
                                    .fontWeight(.medium)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 15)
                                    .background(
                                        isAddDisabled
                                        ? Color.gray.opacity(0.4)
                                        : Color(red: 0.40, green: 0.45, blue: 0.62)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .animation(.easeInOut(duration: 0.2), value: isAddDisabled)
                            }
                            .disabled(isAddDisabled)
                        }
                    } else {
                        Section {
                            Text("Maximum of 5 custom tabs reached.")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    
                    
                    Section(header: Text("Current Locations").foregroundColor(.black)) {
                        let filteredLocations = sortedLocations.filter { $0.name != "All" }
                        
                        ForEach(filteredLocations, id: \.self) { location in
                            if locationBeingRenamed == location {
                                HStack {
                                    TextField("New name", text: $editedName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    HStack(spacing: 12) {
                                        Button(action: confirmRename) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                                .padding(6)
                                        }
                                        .buttonStyle(BorderlessButtonStyle()) // safer than Plain here
                                        .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                        
                                        Button(action: cancelRename) {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.red)
                                                .padding(6)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .contentShape(Rectangle()) // ensures only the buttons are tappable
                                }
                                if renameConflictError {
                                    Text("Cannot rename to \"All\" or an existing name.")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            } else {
                                HStack {
                                    Text(location.name ?? "Unnamed")
                                    Spacer()
                                    Button("Rename") {
                                        locationBeingRenamed = location
                                        editedName = location.name ?? ""
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .onDelete(perform: deleteLocation)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Manage Locations")
        }
    }

    private func deleteLocation(at offsets: IndexSet) {
        let filteredLocations = sortedLocations.filter { $0.name != "All" }

        for offset in offsets {
            let location = filteredLocations[offset]
            viewContext.delete(location)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete location: \(error)")
        }
    }

    private func confirmRename() {
        guard let location = locationBeingRenamed else { return }
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return }

        if trimmed.lowercased() == "all" ||
           locations.contains(where: { $0.name == trimmed && $0 != location }) {
            renameConflictError = true
            return
        }

        renameConflictError = false

        location.name = trimmed
        do {
            try viewContext.save()
        } catch {
            print("Rename failed: \(error)")
        }

        locationBeingRenamed = nil
        editedName = ""
    }

    private func cancelRename() {
        locationBeingRenamed = nil
        editedName = ""
    }
    
    private func handleAddLocation() {
        let trimmed = newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !isAddDisabled else { return }

        let newLocation = LocationEntity(context: viewContext)
        newLocation.name = trimmed

        do {
            try viewContext.save()
            newLocationName = ""
        } catch {
            print("Failed to save location: \(error)")
        }
    }
}
