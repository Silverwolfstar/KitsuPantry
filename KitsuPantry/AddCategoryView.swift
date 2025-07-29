//
//  AddCategoryView.swift
//  KitsuPantry
//
//  Created by Silver on 7/29/25.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [String]
    @State private var newCategoryName: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("New Category Name", text: $newCategoryName)

                Button("Add") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
                    categories.append(trimmed)
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
