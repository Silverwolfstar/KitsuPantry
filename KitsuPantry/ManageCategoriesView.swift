//
//  ManageCategoriesView.swift
//  KitsuPantry
//
//  Created by Silver on 7/29/25.
//

import SwiftUI
import CoreData

struct ManageCategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var categories: [String]
    let defaultCategories: Set<String> = ["All", "Fridge", "Freezer", "Pantry"]

    @State private var renamingCategory: String? = nil
    @State private var newName = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        if defaultCategories.contains(category) {
                            Text(category)
                        } else if renamingCategory == category {
                            TextField("New name", text: $newName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Save") {
                                renameCategory(old: category, new: newName)
                                renamingCategory = nil
                            }
                        } else {
                            Text(category)
                            Spacer()
                            Button("Rename") {
                                renamingCategory = category
                                newName = category
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(role: .destructive) {
                                deleteCategory(category)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Tabs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }

    private func renameCategory(old: String, new: String) {
        if new.isEmpty || categories.contains(new) { return }
        for item in try! viewContext.fetch(FoodItemEntity.fetchRequest()) as! [FoodItemEntity] {
            if item.location == old {
                item.location = new
            }
        }
        if let index = categories.firstIndex(of: old) {
            categories[index] = new
        }
        try? viewContext.save()
    }

    private func deleteCategory(_ category: String) {
        let fallback = "Misc"
        if !categories.contains(fallback) {
            categories.append(fallback)
        }

        for item in try! viewContext.fetch(FoodItemEntity.fetchRequest()) as! [FoodItemEntity] {
            if item.location == category {
                item.location = fallback
            }
        }

        categories.removeAll { $0 == category }
        try? viewContext.save()
    }
}
