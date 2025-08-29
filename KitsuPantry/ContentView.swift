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
    @State private var pickerReloadKey = UUID()

    private func location(for id: NSManagedObjectID?) -> LocationEntity? {
        guard let id else { return nil }
        return try? viewContext.existingObject(with: id) as? LocationEntity
    }
    
    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }
    
    private var segmentSignature: String {
            locations
                .map { $0.objectID.uriRepresentation().absoluteString + "|" + ($0.name ?? "") }
                .joined(separator: ",")
        }

    var body: some View {
        VStack {
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
            .padding(.horizontal)
            .padding(.bottom, 0)

            let selectedLoc = location(for: selectedLocationID)
            ItemsListView(
                filter: selectedLoc == nil || selectedLoc?.name == "All"
                    ? .all
                    : .location(selectedLoc!),
                title: selectedLoc?.name ?? "All",
                locations: .constant(Array(locations))
            )
        }
        .onAppear {
            seedDefaultLocations(context: viewContext)
            if selectedLocationID == nil {
                selectedLocationID = locations.first(where: { $0.name == "All" })?.objectID
            }
        }
        
        .appBackground()
    }
}
