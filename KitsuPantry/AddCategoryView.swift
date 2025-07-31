//
//  AddCategoryView.swift
//  KitsuPantry
//
//  Created by Silver on 7/29/25.
//

import SwiftUI
import CoreData

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var categories: [LocationEntity]
    @State private var newCategoryName: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("New Category Name", text: $newCategoryName)

                Button("Add") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty,
                          !categories.contains(where: { $0.name?.lowercased() == trimmed.lowercased() }) else {
                        return
                    }

                    let newCategory = LocationEntity(context: viewContext)
                    newCategory.name = trimmed

                    try? viewContext.save()

                    dismiss()
                }
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
