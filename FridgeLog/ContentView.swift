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

    @State private var fridgeExpanded  = true
    @State private var freezerExpanded = true
    @State private var pantryExpanded  = true

    var fridgeItems:  [FoodItem] { items.filter { $0.storagePlace == "Fridge"  } }
    var freezerItems: [FoodItem] { items.filter { $0.storagePlace == "Freezer" } }
    var pantryItems:  [FoodItem] { items.filter { $0.storagePlace == "Pantry"  } }

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
                    List {
                        if !fridgeItems.isEmpty {
                            DisclosureGroup(isExpanded: $fridgeExpanded) {
                                ForEach(fridgeItems) { item in
                                    ItemRow(item: item)
                                }
                            } label: {
                                Label("Fridge", systemImage: "refrigerator")
                                    .font(.headline)
                            }
                        }

                        if !freezerItems.isEmpty {
                            DisclosureGroup(isExpanded: $freezerExpanded) {
                                ForEach(freezerItems) { item in
                                    ItemRow(item: item)
                                }
                            } label: {
                                Label("Freezer", systemImage: "snowflake")
                                    .font(.headline)
                            }
                        }

                        if !pantryItems.isEmpty {
                            DisclosureGroup(isExpanded: $pantryExpanded) {
                                ForEach(pantryItems) { item in
                                    ItemRow(item: item)
                                }
                            } label: {
                                Label("Pantry", systemImage: "archivebox")
                                    .font(.headline)
                            }
                        }
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

// MARK: - Item Row
struct ItemRow: View {
    let item: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            Text(item.amount)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
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
