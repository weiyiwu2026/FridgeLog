//
//  ContentView.swift
//  FridgeLog
//
//  Created by WW on 2026-04-09.
//

import SwiftUI

struct ContentView: View {

    @Environment(FoodNameStore.self) private var foodNameStore
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
            ScrollView {
                VStack(spacing: 16) {
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
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        if !fridgeItems.isEmpty {
                            StorageSection(title: "Fridge", icon: "refrigerator",
                                           isExpanded: $fridgeExpanded, items: fridgeItems)
                        }
                        if !freezerItems.isEmpty {
                            StorageSection(title: "Freezer", icon: "snowflake",
                                           isExpanded: $freezerExpanded, items: freezerItems)
                        }
                        if !pantryItems.isEmpty {
                            StorageSection(title: "Pantry", icon: "archivebox",
                                           isExpanded: $pantryExpanded, items: pantryItems)
                        }
                    }
                }
                .padding()
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
                    // Save name + type to the standard list (ignored if name already exists)
                    foodNameStore.add(name: newItem.name, itemType: newItem.itemType)

                    // Merge into an existing entry only when name, storage place,
                    // item type, amount type, AND expiration date all match.
                    if let index = items.firstIndex(where: {
                        $0.name.lowercased() == newItem.name.lowercased() &&
                        $0.storagePlace      == newItem.storagePlace &&
                        $0.itemType          == newItem.itemType &&
                        $0.amountType        == newItem.amountType &&
                        $0.expirationDate    == newItem.expirationDate
                    }) {
                        items[index].amountValue += newItem.amountValue
                    } else {
                        items.append(newItem)
                    }
                    showAddItem = false
                })
            }
        }
    }
}

// MARK: - Collapsible Storage Section
struct StorageSection: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let items: [FoodItem]

    var body: some View {
        VStack(spacing: 0) {
            // Header — tap to expand or collapse
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
            }

            // Expandable rows
            if isExpanded {
                Divider()
                ForEach(items) { item in
                    ItemRow(item: item)
                        .padding(.horizontal)
                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
                Text(item.amountType == .portions ? "Portions: \(item.amountValue)" : "Qty: \(item.amountValue)")
                Text("·")
                Text(item.itemType)
                Text("·")
                Text(expirationText)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

// MARK: - Placeholder Data
let sampleItems: [FoodItem] = [
    FoodItem(name: "Milk",        amountType: .quantity, amountValue: 1,  storagePlace: "Fridge",  itemType: "Dairy & Eggs",    purchaseDate: Date(), estimatedShelfLifeDays: 7,   expirationDate: Calendar.current.date(byAdding: .day, value: 5,  to: Date())),
    FoodItem(name: "Eggs",        amountType: .quantity, amountValue: 12, storagePlace: "Fridge",  itemType: "Dairy & Eggs",    purchaseDate: Date(), estimatedShelfLifeDays: 21,  expirationDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())),
    FoodItem(name: "Frozen Peas", amountType: .quantity, amountValue: 1,  storagePlace: "Freezer", itemType: "Frozen",          purchaseDate: Date(), estimatedShelfLifeDays: 90,  expirationDate: nil),
    FoodItem(name: "Ground Beef", amountType: .portions, amountValue: 4,  storagePlace: "Freezer", itemType: "Meat & Seafood",  purchaseDate: Date(), estimatedShelfLifeDays: 120, expirationDate: nil),
    FoodItem(name: "Rice",        amountType: .quantity, amountValue: 2,  storagePlace: "Pantry",  itemType: "Pantry",          purchaseDate: Date(), estimatedShelfLifeDays: 365, expirationDate: nil),
]

#Preview {
    ContentView()
}
