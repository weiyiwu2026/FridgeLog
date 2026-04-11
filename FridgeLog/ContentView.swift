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
                AddItemMethodView(onItemSaved: { newItem in
                    // Merge into an existing entry only when name, storage place,
                    // item type, AND expiration date all match.
                    if let index = items.firstIndex(where: {
                        $0.name.lowercased() == newItem.name.lowercased() &&
                        $0.storagePlace       == newItem.storagePlace &&
                        $0.itemType           == newItem.itemType &&
                        $0.expirationDate     == newItem.expirationDate
                    }) {
                        items[index].quantity += newItem.quantity
                    } else {
                        items.append(newItem)
                    }
                    showAddItem = false
                })
            }
        }
    }
}

// MARK: - Item Row
struct ItemRow: View {
    let item: FoodItem

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private var expirationText: String {
        if let date = item.expirationDate {
            return "Expires: \(Self.dateFormatter.string(from: date))"
        } else {
            return "No expiration date"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            HStack(spacing: 8) {
                Text("Qty: \(item.quantity)")
                Text("·")
                Text(item.itemType)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Text(expirationText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Placeholder Data
let sampleItems: [FoodItem] = [
    FoodItem(name: "Milk",        quantity: 1,  storagePlace: "Fridge",  itemType: "Dairy",    purchaseDate: Date(), estimatedShelfLifeDays: 7,   expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())),
    FoodItem(name: "Eggs",        quantity: 12, storagePlace: "Fridge",  itemType: "Produce",  purchaseDate: Date(), estimatedShelfLifeDays: 21,  expirationDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())),
    FoodItem(name: "Frozen Peas", quantity: 1,  storagePlace: "Freezer", itemType: "Frozen",   purchaseDate: Date(), estimatedShelfLifeDays: 90,  expirationDate: nil),
    FoodItem(name: "Rice",        quantity: 2,  storagePlace: "Pantry",  itemType: "Packaged", purchaseDate: Date(), estimatedShelfLifeDays: 365, expirationDate: nil),
]

#Preview {
    ContentView()
}
