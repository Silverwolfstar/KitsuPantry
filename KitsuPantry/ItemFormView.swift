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
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("showObtainedDate") private var showObtainedDate = true
    @State private var obtainedDate = Date()

    @Binding var locations: [LocationEntity]

    // Form fields
    @State private var name = ""
    @State private var quantity: Double = 1
    @State private var expirationDate = Date()
    @State private var notes = ""
    @State private var selectedLocation: LocationEntity?
    @State private var quantityText: String = "1"

    // Focus management
    @FocusState private var quantityFieldIsFocused: Bool

    private var title: String {
        switch mode {
        case .add: return "Add Item"
        case .edit: return "Edit Item"
        }
    }
    
    private var sortedLocations: [LocationEntity] {
        let all = locations.first(where: { $0.name == "All" })
        let others = locations.filter { $0.name != "All" }
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

    private var quantityIsValid: Bool {
        if let value = Double(quantityText), value > 0 {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top){
                Color(red: 0.72, green: 0.78, blue: 0.89)
                    .ignoresSafeArea()
                Form {
                    Section(header: Text("Item Info").foregroundColor(.black)) {
                        TextField("Name", text: $name)
                        Picker("Location", selection: $selectedLocation) {
                            Text("Miscellaneous").tag(nil as LocationEntity?)
                            ForEach(sortedLocations.filter { $0.name != "All" }, id: \.self) { cat in Text(cat.name ?? "Unnamed").tag(cat as LocationEntity?)
                            }
                        }
                        
                        HStack {
                            Text("Quantity")
                            Spacer()
                            TextField("", text: $quantityText)
                                .frame(width: 80)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
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
                        
                        if !quantityIsValid && !quantityText.isEmpty {
                            Text("Quantity must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                        
                        if showObtainedDate {
                            DatePicker("Obtained Date", selection: $obtainedDate, displayedComponents: .date)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.3))
                                    )
                                
                                TextEditor(text: $notes)
                                    .padding(4)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .background(Color.clear) // prevent TextEditor from overriding ZStack
                            }
                            .frame(minHeight: 80)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
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
                        item.location = selectedLocation
                        guard let parsedQuantity = Double(quantityText),
                              parsedQuantity > 0 else {
                            return  // Don't save if empty or zero
                        }
                        item.quantity = Double(round(100 * parsedQuantity) / 100)
                        item.expirationDate = expirationDate
                        item.obtainedDate = obtainedDate
                        item.notes = notes
                        
                        try? viewContext.save()
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespaces).isEmpty || !quantityIsValid
                    )
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
                        selectedLocation = locations.first(where: { $0.name == loc })
                    } else {
                        selectedLocation = nil
                    }
                    quantityText = "1"
                    obtainedDate = Date()
                case .edit(let item):
                    name = item.name ?? ""
                    selectedLocation = item.location
                    expirationDate = item.expirationDate ?? Date()
                    obtainedDate = item.obtainedDate ?? Date()
                    notes = item.notes ?? ""
                    
                    //quantity formatting
                    quantity = Double(item.quantity)
                    quantityText = String(format: "%.2f", item.quantity)
                        .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
                }
            }
        }
    }
}
