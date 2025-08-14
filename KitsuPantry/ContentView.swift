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

    @State private var selectedLocation: LocationEntity?

    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }

    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLocation) {
                ForEach(sortedLocations, id: \.self) { location in
                    Text(location.name ?? "Unnamed").tag(location as LocationEntity?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 0)

            ItemsListView(
                filter: selectedLocation == nil || selectedLocation?.name == "All"
                    ? .all
                    : .location(selectedLocation!),
                title: selectedLocation?.name ?? "All",
                locations: .constant(Array(locations))  // You’re not editing here, so .constant is fine
            )
        }
        .onAppear {
            seedDefaultLocations(context: viewContext)
            if selectedLocation == nil {
                selectedLocation = locations.first(where: { $0.name == "All" })
            }
        }
    }
}
