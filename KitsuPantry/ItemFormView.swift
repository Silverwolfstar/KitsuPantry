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
    @State private var quantity: Double = 1
    @State private var expirationDate = Date()
    @State private var notes = ""
    @State private var selectedCategory: CategoryEntity?
    @State private var quantityText: String = "1"

    // Focus management
    @FocusState private var quantityFieldIsFocused: Bool

    private var title: String {
        switch mode {
        case .add: return "Add Item"
        case .edit: return "Edit Item"
        }
    }
    
    private var sortedCategories: [CategoryEntity] {
        let all = categories.first(where: { $0.name == "All" })
        let others = categories.filter { $0.name != "All" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
        return (all != nil) ? [all!] + others : others
    }

    private var quantityFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0.01
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2 // Allows e.g. 1.5 or 1.25
        formatter.alwaysShowsDecimalSeparator = false
        formatter.usesSignificantDigits = false
        return formatter
    }
    
    private func cleanDecimalInput(_ input: String) -> String {
        // Only allow digits and one decimal point
        var filtered = input.filter { "0123456789.".contains($0) }

        // Prevent multiple dots
        let components = filtered.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if components.count > 2 {
            filtered = components[0] + "." + components[1]
        }

        // Limit to two decimal places
        if let dotIndex = filtered.firstIndex(of: ".") {
            let afterDot = filtered[filtered.index(after: dotIndex)...]
            if afterDot.count > 2 {
                let prefix = filtered[..<filtered.index(after: dotIndex)]
                let suffix = afterDot.prefix(2)
                filtered = String(prefix + suffix)
            }
        }

        // Cap total length to 8 characters
        if filtered.count > 8 {
            filtered = String(filtered.prefix(8))
        }

        return filtered
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $selectedCategory) {
                        Text("Uncategorized").tag(nil as CategoryEntity?)
                        ForEach(sortedCategories.filter { $0.name != "All" }, id: \.self) { cat in Text(cat.name ?? "Unnamed").tag(cat as CategoryEntity?)
                        }
                    }

                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("", text: $quantityText)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                            .focused($quantityFieldIsFocused)
                            .onChange(of: quantityText) {
                                let cleaned = cleanDecimalInput(quantityText)
                                    quantityText = cleaned
                                    if let num = Double(cleaned) {
                                        quantity = num
                                    }
                                }
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
                        if let parsedQuantity = Double(quantityText) {
                            item.quantity = Double(round(100 * parsedQuantity) / 100)
                        } else {
                            item.quantity = 1  // fallback default
                        }
                        item.expirationDate = expirationDate
                        item.notes = notes

                        try? viewContext.save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
                        selectedCategory = nil
                    }
                    quantityText = "1"
                case .edit(let item):
                    name = item.name ?? ""
                    selectedCategory = item.category
                    expirationDate = item.expirationDate ?? Date()
                    notes = item.notes ?? ""
                    
                    //quantity formatting
                    quantity = Double(item.quantity)
                    print("Loaded quantity:", item.quantity)

                    quantityText = String(format: "%.2f", item.quantity)
                        .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
                    
//                    if let formatted = quantityFormatter.string(from: NSNumber(value: item.quantity)) {
//                        quantityText = formatted
//                    } else {
//                        quantityText = "1"
//                    }
                }
            }
        }
    }
}
