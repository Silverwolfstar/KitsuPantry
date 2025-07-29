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

    @State private var categories: [String] = ["All", "Fridge", "Freezer", "Pantry"]
    @State private var selectedCategory: String = "All"
    @State private var showAddCategorySheet = false

    var body: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
                Text("+").tag("+")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedCategory) { newValue in
                if newValue == "+" {
                    showAddCategorySheet = true
                    selectedCategory = categories.first ?? "All"
                }
            }

            ItemsListView(
                filter: selectedCategory == "All" ? .all : .location(selectedCategory),
                title: selectedCategory,
                categories: $categories
            )
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView(categories: $categories)
        }
        .onAppear {
            seedDefaultCategories(context: viewContext)
        }
    }
}
