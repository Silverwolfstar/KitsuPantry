//
//  ManageCategoriesView.swift
//  KitsuPantry
//
//  Created by Silver on 7/30/25.
//

import SwiftUI
import CoreData

struct ManageCategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var categories: [CategoryEntity]
    @State private var newCategoryName: String = ""

    var body: some View {
        Form {
            Section(header: Text("Add New Category")) {
                TextField("New Category Name", text: $newCategoryName)

                Button("Add") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty,
                          !categories.contains(where: { $0.name == trimmed }) else { return }

                    let newCategory = CategoryEntity(context: viewContext)
                    newCategory.name = trimmed

                    do {
                        try viewContext.save()
                        categories.append(newCategory)
                        newCategoryName = ""
                    } catch {
                        print("Failed to save category: \(error)")
                    }
                }
                .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section(header: Text("Current Categories")) {
                ForEach(categories.filter { $0.name != "All" }, id: \.self) { category in
                    Text(category.name ?? "Unnamed")
                }
                .onDelete(perform: deleteCategory)
            }
        }
        .navigationTitle("Manage Categories")
    }

    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            viewContext.delete(category)
        }

        do {
            try viewContext.save()
            categories.remove(atOffsets: offsets)
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}
