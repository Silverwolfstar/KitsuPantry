//
//  ContentView.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let quantity: Int
    let expirationDate: Date
    let notes: String
}

struct ContentView: View {
    @State private var items: [FoodItem] = [
        FoodItem(name: "Milk", location: "Fridge", quantity: 1, expirationDate: Date().addingTimeInterval(86400 * 3), notes: "")
    ]
    
    @State private var showingAddItem = false

    var body: some View {
        NavigationView {
            List {
                // Existing items
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name).font(.headline)
                        Text("\(item.location) — Qty: \(item.quantity)")
                        Text("Expires: \(formatted(date: item.expirationDate))")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if !item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Notes:\n" + item.notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // "+" button as part of the list
                Button(action: {
                    showingAddItem = true
                }) {
                    HStack {
                        Spacer()
                        Text("+")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 6)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("KitsuPantry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView { newItem in
                items.append(newItem)
            }
        }
    }

    func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
