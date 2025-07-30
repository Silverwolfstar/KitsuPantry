//
//  AddItemView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

enum FormMode {
    case add(defaultLocation: String? = nil)
    case edit(FoodItemEntity)
}

struct ItemFormView: View {
    let mode: FormMode
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @Binding var categories: [CategoryEntity]

    // Form fields
    @State private var name = ""
    @State private var quantity = 1
    @State private var expirationDate = Date()
    @State private var notes = ""
    @State private var selectedCategory: CategoryEntity?

    // Focus management
    @FocusState private var quantityFieldIsFocused: Bool

    private var title: String {
        switch mode {
        case .add: return "Add Item"
        case .edit: return "Edit Item"
        }
    }

    // If it crashes again I will cry
    private var quantityFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.self) { cat in
                            Text(cat.name ?? "Unnamed").tag(cat as CategoryEntity?)
                        }
                    }

                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("", value: $quantity, formatter: quantityFormatter)
                            .frame(width: 60)
                            .keyboardType(.numberPad)
                            .focused($quantityFieldIsFocused)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        quantityFieldIsFocused = true
                    }

                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .background(Color.white)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item: FoodItemEntity
                        switch mode {
                        case .add:
                            item = FoodItemEntity(context: viewContext)
                        case .edit(let existingItem):
                            item = existingItem
                        }

                        item.name = name
                        item.category = selectedCategory
                        item.quantity = Int16(quantity)
                        item.expirationDate = expirationDate
                        item.notes = notes

                        try? viewContext.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                switch mode {
                case .add(let defaultLoc):
                    if let loc = defaultLoc {
                        selectedCategory = categories.first(where: { $0.name == loc })
                    } else {
                        selectedCategory = categories.first(where: { !($0.name ?? "").elementsEqual("All") })
                    }
                case .edit(let item):
                    name = item.name ?? ""
                    selectedCategory = item.category
                    quantity = Int(item.quantity)
                    expirationDate = item.expirationDate ?? Date()
                    notes = item.notes ?? ""
                }
            }
        }
    }
}
