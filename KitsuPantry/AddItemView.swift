//
//  AddItemView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var location = "Fridge"
    @State private var quantity = 1
    @State private var expirationDate = Date()
    @State private var notes = ""
    @FocusState private var quantityFieldIsFocused: Bool

    let locations = ["Fridge", "Freezer", "Pantry"]

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
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = FoodItemEntity(context: viewContext)
                        newItem.name = name
                        newItem.location = location
                        newItem.quantity = Int16(quantity)
                        newItem.expirationDate = expirationDate
                        newItem.notes = notes
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
        }
    }
}
