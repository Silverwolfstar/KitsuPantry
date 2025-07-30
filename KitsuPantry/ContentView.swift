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
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<CategoryEntity>

    @State private var selectedCategory: CategoryEntity?

    var body: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category.name ?? "Unnamed").tag(category as CategoryEntity?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ItemsListView(
                filter: selectedCategory == nil || selectedCategory?.name == "All"
                    ? .all
                    : .category(selectedCategory!),
                title: selectedCategory?.name ?? "All",
                categories: .constant(Array(categories))  // You can pass a constant if not editing
            )
        }
        .onAppear {
            seedDefaultCategories(context: viewContext)
            if selectedCategory == nil {
                selectedCategory = categories.first(where: { $0.name == "All" })
            }
        }
    }
}
