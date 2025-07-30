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
    case category(CategoryEntity)
}

struct ItemsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var categories: [CategoryEntity]

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

    init(filter: ItemFilter, title: String, categories: Binding<[CategoryEntity]>) {
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
        case .category(let category):
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                predicate: NSPredicate(format: "category == %@", category),
                animation: .default
            )
            self.defaultLocationForAdd = category.name

            self._categories = categories
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name ?? "Unnamed")
                            .font(.headline)

                        let categoryName = item.category?.name ?? "Unknown"
                        let qty = Int(item.quantity)
                        Text("\(categoryName) — Qty: \(qty)")

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
                    ItemFormView(mode: .add(defaultLocation: defaultLoc), categories: $categories)
                case .edit(let item):
                    ItemFormView(mode: .edit(item), categories: $categories)
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
