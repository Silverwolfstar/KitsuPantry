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

    @FetchRequest(
        entity: LocationEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default
    ) private var locations: FetchedResults<LocationEntity>

    @State private var selectedLocationID: NSManagedObjectID?
    
    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }
    
    private var selectedLocation: LocationEntity? {
        guard let id = selectedLocationID else { return nil }
        return try? viewContext.existingObject(with: id) as? LocationEntity
    }

    private var currentTitle: String {
        selectedLocation?.name ?? "All"
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedTabs(
                items: sortedLocations.map(\.objectID),
                title: { id in
                    (try? viewContext.existingObject(with: id) as? LocationEntity)?.name ?? "?"
                },
                selection: Binding(
                    get: {
                        selectedLocationID
                        ?? locations.first(where: { $0.name == "All" })?.objectID
                        ?? sortedLocations.first?.objectID
                        ?? {
                            selectedLocationID!
                        }()
                    },
                    set: { newID in
                        selectedLocationID = newID
                    }
                )
            )
            .padding(.bottom, 0)
            
            ItemsListView(
                filter: selectedLocation == nil || selectedLocation?.name == "All"
                    ? .all
                : .location(selectedLocation!),
                title: currentTitle,
                locations: .constant(Array(locations))
            )
        }
        .onAppear {
            seedDefaultLocations(context: viewContext)
            if selectedLocationID == nil {
                selectedLocationID = locations.first(where: { $0.name == "All" })?.objectID ?? sortedLocations.first?.objectID
            }
        }
        .appBackground()
    }
}
