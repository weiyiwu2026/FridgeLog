//
//  ContentView.swift
//  FridgeLog
//
//  Created by WW on 2026-04-09.
//

import SwiftUI

struct ContentView: View {

    @State private var items: [FoodItem] = sampleItems
    @State private var showAddItem = false

    var body: some View {
        NavigationView {
            Group {
                if items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "refrigerator")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No food added yet.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Tap + to add your first item.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)
                            Text("\(item.amount)  ·  \(item.storagePlace)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("FridgeLog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddItem = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemMethodView()
            }
        }
    }
}

// MARK: - Placeholder Data
let sampleItems: [FoodItem] = [
    FoodItem(name: "Milk",        amount: "1 carton",  storagePlace: "Fridge"),
    FoodItem(name: "Eggs",        amount: "12",        storagePlace: "Fridge"),
    FoodItem(name: "Frozen Peas", amount: "1 bag",     storagePlace: "Freezer"),
    FoodItem(name: "Rice",        amount: "2 lbs",     storagePlace: "Pantry"),
]

#Preview {
    ContentView()
}
