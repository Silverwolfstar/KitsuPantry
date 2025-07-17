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
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.name).font(.headline)
                    Text("\(item.location) — Qty: \(item.quantity)")
                    Text("Expires: \(formatted(date: item.expirationDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("KitsuPantry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView { newItem in
                    items.append(newItem)
                }
            }
        }
    }

    func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
