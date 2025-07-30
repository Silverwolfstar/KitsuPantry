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
    case location(String)
}

struct ItemsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var categories: [String]

    @FetchRequest private var items: FetchedResults<FoodItemEntity>

    enum ActiveSheet: Identifiable {
        case add(defaultLocation: String?)
        case edit(FoodItemEntity)

        var id: AnyHashable {
            switch self {
            case .add:
                return UUID()
            case .edit(let item):
                return item.objectID
            }
        }
    }

    @State private var activeSheet: ActiveSheet?
    private let title: String
    private let defaultLocationForAdd: String?

    init(filter: ItemFilter, title: String, categories: Binding<[String]>) {
        self.title = title
        switch filter {
        case .all:
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                animation: .default
            )
            self.defaultLocationForAdd = nil
            self._categories = categories
        case .location(let loc):
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                predicate: NSPredicate(format: "location == %@", loc),
                animation: .default
            )
            self.defaultLocationForAdd = loc
            self._categories = categories
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unnamed").font(.headline)
                        Text("\(item.location ?? "Unknown") — Qty: \(item.quantity)")
                        if let date = item.expirationDate {
                            Text("Expires: \(formatted(date: date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let notes = item.notes,
                           !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                    NavigationLink(destination: SettingsView(categories: $categories)) {
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
                    ItemFormView(mode: .add(defaultLocation: defaultLoc))
                case .edit(let item):
                    ItemFormView(mode: .edit(item))
                }
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
