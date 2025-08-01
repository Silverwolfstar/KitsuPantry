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

    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }

    var body: some View {
        Form {
            Section(header: Text("Add New Location")) {
                TextField("New Location Name", text: $newLocationName)

                Button("Add") {
                    let trimmed = newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty,
                          !locations.contains(where: { $0.name == trimmed }) else { return }

                    let newLocation = LocationEntity(context: viewContext)
                    newLocation.name = trimmed

                    do {
                        try viewContext.save()
                        newLocationName = ""
                    } catch {
                        print("Failed to save location: \(error)")
                    }
                }
                .disabled(newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section(header: Text("Current Locations")) {
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
        .navigationTitle("Manage Locations")
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

        guard !trimmed.isEmpty,
              trimmed != "All",
              !locations.contains(where: { $0.name == trimmed && $0 != location }) else {
            return
        }

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
}
