import SwiftUI

// MARK: - Current Food List Screen

struct CurrentFoodListView: View {

    @Binding var items: [FoodItem]
    let onItemSaved:    (FoodItem) -> Void
    let onItemDeleted:  (FoodItem) -> Void

    @Environment(ToBuyStore.self) private var toBuyStore

    @State private var showAddItem     = false
    @State private var fridgeExpanded  = true
    @State private var freezerExpanded = true
    @State private var pantryExpanded  = true

    // ── Search & Filter state ─────────────────────────────────
    @State private var searchText:            String  = ""
    @State private var selectedStoragePlace:  String? = nil   // nil = All
    @State private var selectedItemType:      String? = nil   // nil = All

    // ── Derived data ──────────────────────────────────────────

    // Unique item types present in the inventory, shown in the filter menu.
    private var availableItemTypes: [String] {
        Array(Set(items.map { $0.itemType })).sorted()
    }

    // Items after applying search text + both filter selections.
    private var filteredItems: [FoodItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText)
            let matchesPlace  = selectedStoragePlace == nil ||
                item.storagePlace == selectedStoragePlace
            let matchesType   = selectedItemType == nil ||
                item.itemType == selectedItemType
            return matchesSearch && matchesPlace && matchesType
        }
    }

    var fridgeItems:  [FoodItem] { filteredItems.filter { $0.storagePlace == "Fridge"  } }
    var freezerItems: [FoodItem] { filteredItems.filter { $0.storagePlace == "Freezer" } }
    var pantryItems:  [FoodItem] { filteredItems.filter { $0.storagePlace == "Pantry"  } }

    private var isFiltering: Bool { selectedStoragePlace != nil || selectedItemType != nil }

    // ── View ──────────────────────────────────────────────────

    var body: some View {
        Group {
            if items.isEmpty {
                // ── No items added yet ────────────────────────
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

            } else if filteredItems.isEmpty {
                // ── Items exist but search/filter found nothing ──
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No items match.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Try a different search or filter.")
                        .foregroundColor(.secondary)
                    Button("Clear Search & Filters") { clearAll() }
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                // ── Filtered list with collapsible sections ───
                List {
                    if !fridgeItems.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $fridgeExpanded) {
                                ForEach(fridgeItems) { item in
                                    ItemRow(item: item)
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                onItemDeleted(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
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
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                onItemDeleted(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
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
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                onItemDeleted(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
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
        // ── Search bar ────────────────────────────────────────
        .searchable(text: $searchText, prompt: "Search items")
        // ── Toolbar ───────────────────────────────────────────
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {

                // Filter menu (filled icon when any filter is active)
                Menu {
                    Section("Storage Place") {
                        Button { selectedStoragePlace = nil } label: {
                            selectedStoragePlace == nil
                                ? Label("All", systemImage: "checkmark")
                                : Label("All", systemImage: "")
                        }
                        ForEach(["Fridge", "Freezer", "Pantry"], id: \.self) { place in
                            Button { selectedStoragePlace = place } label: {
                                selectedStoragePlace == place
                                    ? Label(place, systemImage: "checkmark")
                                    : Label(place, systemImage: "")
                            }
                        }
                    }

                    Section("Item Type") {
                        Button { selectedItemType = nil } label: {
                            selectedItemType == nil
                                ? Label("All", systemImage: "checkmark")
                                : Label("All", systemImage: "")
                        }
                        ForEach(availableItemTypes, id: \.self) { type in
                            Button { selectedItemType = type } label: {
                                selectedItemType == type
                                    ? Label(type, systemImage: "checkmark")
                                    : Label(type, systemImage: "")
                            }
                        }
                    }
                } label: {
                    Image(systemName: isFiltering
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }

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

    // MARK: - Helpers

    private func clearAll() {
        searchText           = ""
        selectedStoragePlace = nil
        selectedItemType     = nil
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
        CurrentFoodListView(items: .constant(sampleItems), onItemSaved: { _ in }, onItemDeleted: { _ in })
    }
    .environment(ToBuyStore())
    .environment(FoodNameStore())
}
