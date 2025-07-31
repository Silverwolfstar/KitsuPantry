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
    @Binding var locations: [LocationEntity]
    @State private var newLocationName: String = ""
    
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
                        locations.append(newLocation)
                        newLocationName = ""
                    } catch {
                        print("Failed to save location: \(error)")
                    }
                }
                .disabled(newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section(header: Text("Current Locations")) {
                let filteredLocations = locations.filter { $0.name != "All" }
                
                ForEach(filteredLocations, id: \.self) { location in
                    Text(location.name ?? "Unnamed")
                }
                .onDelete { offsets in
                    let originalIndexes = offsets.map { offset in
                        locations.firstIndex(of: filteredLocations[offset])!
                    }
                    deleteLocation(at: IndexSet(originalIndexes))
                }
            }
        }
        .navigationTitle("Manage Locations")
    }

    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            viewContext.delete(location)
        }

        do {
            try viewContext.save()
            locations.remove(atOffsets: offsets)
        } catch {
            print("Failed to delete location: \(error)")
        }
    }
}
