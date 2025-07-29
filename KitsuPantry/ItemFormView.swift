//
//  AddItemView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

enum FormMode {
    case add
    case edit(FoodItemEntity)
}

struct ItemFormView: View {
    let mode: FormMode
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // Form fields
    @State private var name = ""
    @State private var location = "Fridge"
    @State private var quantity = 1
    @State private var expirationDate = Date()
    @State private var notes = ""

    // Focus management
    @FocusState private var quantityFieldIsFocused: Bool

    let locations = ["Fridge", "Freezer", "Pantry"]

    private var title: String {
        switch mode {
        case .add: return "Add Item"
        case .edit: return "Edit Item"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)

                    Picker("Location", selection: $location) {
                        ForEach(locations, id: \.self) { loc in
                            Text(loc)
                        }
                    }

                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("", value: $quantity, formatter: NumberFormatter())
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
                        item.location = location
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
                if case let .edit(existingItem) = mode {
                    name = existingItem.name ?? ""
                    location = existingItem.location ?? "Fridge"
                    quantity = Int(existingItem.quantity)
                    expirationDate = existingItem.expirationDate ?? Date()
                    notes = existingItem.notes ?? ""
                }
            }
            
        }
    }
}
