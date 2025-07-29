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
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<FoodItemEntity>
    
    enum ActiveSheet: Identifiable {
        case add
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
            .navigationTitle("KitsuPantry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { activeSheet = .add }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    ItemFormView(mode: .add)
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
