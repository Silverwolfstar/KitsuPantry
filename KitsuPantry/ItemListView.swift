//
//  ItemListView.swift
//  KitsuPantry
//
//  Created by Silver on 7/29/25.
//

import SwiftUI
import CoreData

enum ItemFilter {
    case all
    case location(LocationEntity)
}

struct ItemsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isManagingTabs = false
    @Binding var locations: [LocationEntity]

    @FetchRequest private var items: FetchedResults<FoodItemEntity>

    enum ActiveSheet: Identifiable {
        case add(defaultLocation: String?)
        case edit(FoodItemEntity)

        var id: AnyHashable {
            switch self {
            case .add(let defaultLocation):
                return defaultLocation ?? "new"
            case .edit(let item):
                return item.objectID
            }
        }
    }

    @State private var activeSheet: ActiveSheet?
    private let title: String
    private let defaultLocationForAdd: String?

    init(filter: ItemFilter, title: String, locations: Binding<[LocationEntity]>) {
        self.title = title
        self._locations = locations

        switch filter {
        case .all:
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                animation: .default
            )
            self.defaultLocationForAdd = nil
        case .location(let location):
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                predicate: NSPredicate(format: "location == %@", location), // ✅ new relationship key
                animation: .default
            )
            self.defaultLocationForAdd = location.name
        }
    }


    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name ?? "Unnamed")
                            .font(.headline)

                        let locationName = item.location?.name ?? "Unknown"
                        let formattedQty = String(format: "%.2f", item.quantity)
                            .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)

                        Text("\(locationName) — Qty: \(formattedQty)")

                        if let date = item.expirationDate {
                            Text("Expires: \(formatted(date: date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        if let notes = item.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !notes.isEmpty {
                            Text("Notes:\n\(notes)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }
                    .onTapGesture {
                        activeSheet = .edit(item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isManagingTabs = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .add(defaultLocation: defaultLocationForAdd)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add(let defaultLoc):
                    ItemFormView(mode: .add(defaultLocation: defaultLoc), locations: $locations)
                case .edit(let item):
                    ItemFormView(mode: .edit(item), locations: $locations)
                }
            }
            .navigationDestination(isPresented: $isManagingTabs) {
                SettingsView()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(items[index])
        }
        try? viewContext.save()
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
