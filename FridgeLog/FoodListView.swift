import SwiftUI

// MARK: - Current Food List Screen

struct CurrentFoodListView: View {

    @Binding var items: [FoodItem]
    let onItemSaved: (FoodItem) -> Void

    @Environment(ToBuyStore.self) private var toBuyStore

    @State private var showAddItem     = false
    @State private var fridgeExpanded  = true
    @State private var freezerExpanded = true
    @State private var pantryExpanded  = true

    var fridgeItems:  [FoodItem] { items.filter { $0.storagePlace == "Fridge"  } }
    var freezerItems: [FoodItem] { items.filter { $0.storagePlace == "Freezer" } }
    var pantryItems:  [FoodItem] { items.filter { $0.storagePlace == "Pantry"  } }

    var body: some View {
        Group {
            if items.isEmpty {
                // ── Empty state ───────────────────────────────
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // ── List with collapsible sections ────────────
                // List (not ScrollView) is required for native swipe actions.
                // DisclosureGroup preserves the expand/collapse behaviour.
                // Swipe left on any row → blue "Buy List" button.
                List {
                    if !fridgeItems.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $fridgeExpanded) {
                                ForEach(fridgeItems) { item in
                                    ItemRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                toBuyStore.add(ToBuyItem(name: item.name))
                                            } label: {
                                                Label("Buy List", systemImage: "cart.badge.plus")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            } label: {
                                Label("Fridge", systemImage: "refrigerator")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    if !freezerItems.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $freezerExpanded) {
                                ForEach(freezerItems) { item in
                                    ItemRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                toBuyStore.add(ToBuyItem(name: item.name))
                                            } label: {
                                                Label("Buy List", systemImage: "cart.badge.plus")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            } label: {
                                Label("Freezer", systemImage: "snowflake")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    if !pantryItems.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $pantryExpanded) {
                                ForEach(pantryItems) { item in
                                    ItemRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                toBuyStore.add(ToBuyItem(name: item.name))
                                            } label: {
                                                Label("Buy List", systemImage: "cart.badge.plus")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            } label: {
                                Label("Pantry", systemImage: "archivebox")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Current Food List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddItem = true }) {
                    Image(systemName: "plus").font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemMethodView(onItemSaved: { newItem in
                onItemSaved(newItem)
                showAddItem = false
            })
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
        "Exp: \(Self.dateFormatter.string(from: item.expirationDate))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            HStack(spacing: 8) {
                Text(item.amountType == .portions ? "Prt: \(item.amountValue)" : "Qty: \(item.amountValue)")
                Text("·")
                Text(item.itemType)
                Text("·")
                Text(expirationText)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationView {
        CurrentFoodListView(items: .constant(sampleItems), onItemSaved: { _ in })
    }
    .environment(ToBuyStore())
    .environment(FoodNameStore())
}
