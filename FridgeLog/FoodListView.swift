import SwiftUI

// MARK: - Current Food List Screen

struct CurrentFoodListView: View {

    @Binding var items: [FoodItem]
    let onItemSaved: (FoodItem) -> Void

    @Environment(ToBuyStore.self)        private var toBuyStore
    @Environment(FoodItemStore.self)     private var foodItemStore
    @Environment(ConsumptionStore.self)  private var consumptionStore

    @State private var showAddItem     = false
    @State private var fridgeExpanded  = true
    @State private var freezerExpanded = true
    @State private var pantryExpanded  = true

    // ── Edit / Consumed sheet state ───────────────────────────
    @State private var editingItem:    FoodItem? = nil
    @State private var consumingItem:  FoodItem? = nil

    // ── Swipe action debounce ─────────────────────────────────
    // Prevents the double-fire bug in SwiftUI swipeActions inside DisclosureGroup.
    @State private var lastToListID: UUID? = nil

    // ── Double-tap hint ───────────────────────────────────────
    @AppStorage("myFoodDoubleTapHintDismissed") private var hintDismissed = false

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
                    Button("Clear Search & Filters") { clearFilters() }
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
                                        .onTapGesture(count: 2) { openEdit(item) }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            consumedButton(for: item)
                                            toListButton(for: item)
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
                                        .onTapGesture(count: 2) { openEdit(item) }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            consumedButton(for: item)
                                            toListButton(for: item)
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
                                        .onTapGesture(count: 2) { openEdit(item) }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            consumedButton(for: item)
                                            toListButton(for: item)
                                        }
                                }
                            } label: {
                                Label("Pantry", systemImage: "archivebox")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // ── Double-tap hint (shown until first use) ───
                    if !hintDismissed {
                        Section {
                            Label("Double-tap any item to edit it.", systemImage: "hand.tap")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("My Food")
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
        // ── Add new item sheet ────────────────────────────────
        .sheet(isPresented: $showAddItem) {
            AddItemMethodView(onItemSaved: { newItem in
                onItemSaved(newItem)
                showAddItem = false
            })
        }
        // ── Consumed sheet ────────────────────────────────────
        .sheet(item: $consumingItem) { item in
            ConsumedSheetView(item: item) { amount in
                consumptionStore.add(ConsumptionRecord(
                    foodName:         item.name,
                    itemType:         item.itemType,
                    storagePlace:     item.storagePlace,
                    purchaseLocation: item.purchaseLocation,
                    amountConsumed:   min(amount, item.amountValue),
                    dateConsumed:     Date()
                ))
                foodItemStore.consume(item, amount: amount)
                consumingItem = nil
            } onCancel: {
                consumingItem = nil
            }
        }
        // ── Edit existing item sheet ──────────────────────────
        .sheet(item: $editingItem) { originalItem in
            NavigationView {
                ManualEntryView(
                    onSave: { updatedItem in
                        foodItemStore.replace(id: originalItem.id, with: updatedItem)
                        editingItem = nil
                    },
                    prefill: originalItem,
                    showCancelButton: true
                )
            }
        }
    }

    // MARK: - Swipe Action Buttons

    @ViewBuilder
    private func toListButton(for item: FoodItem) -> some View {
        Button {
            // Guard against the SwiftUI double-fire bug in DisclosureGroup + swipeActions.
            // If the same item's button fires again before the user starts a new gesture,
            // ignore the second call.
            guard lastToListID != item.id else { return }
            lastToListID = item.id
            toBuyStore.addFromFood(name: item.name, store: item.purchaseLocation, quantity: item.amountValue)
            // Clear the guard after a short delay so future intentional taps work normally.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if lastToListID == item.id { lastToListID = nil }
            }
        } label: {
            Label("To List", systemImage: "cart.badge.plus")
        }
        .tint(.blue)
    }

    @ViewBuilder
    private func consumedButton(for item: FoodItem) -> some View {
        Button {
            consumingItem = item
        } label: {
            Label("Consumed", systemImage: "fork.knife")
        }
        .tint(.green)
    }

    @ViewBuilder
    private func incrementButton(for item: FoodItem) -> some View {
        Button {
            foodItemStore.increment(item)
        } label: {
            Label("+", systemImage: "plus")
        }
        .tint(.green)
    }

    @ViewBuilder
    private func decrementButton(for item: FoodItem) -> some View {
        Button {
            foodItemStore.decrement(item)
        } label: {
            Label("-", systemImage: "minus")
        }
        .tint(.orange)
    }

    @ViewBuilder
    private func deleteButton(for item: FoodItem) -> some View {
        Button(role: .destructive) {
            foodItemStore.delete(item)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Helpers

    private func openEdit(_ item: FoodItem) {
        editingItem = item
        hintDismissed = true
    }

    private func clearFilters() {
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
                Text(expirationText)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Consumed Sheet

struct ConsumedSheetView: View {

    let item:     FoodItem
    let onSave:   (Int) -> Void
    let onCancel: () -> Void

    @State private var inputText: String = "1"

    // Parsed value from the text field; falls back to 1 if invalid.
    private var consumedAmount: Int {
        max(1, Int(inputText.trimmingCharacters(in: .whitespaces)) ?? 1)
    }

    var body: some View {
        NavigationView {
            Form {
                // ── Item summary ──────────────────────────────
                Section {
                    LabeledContent("Item",        value: item.name)
                    LabeledContent("Current Qty", value: "\(item.amountValue)")
                }

                // ── Amount input ──────────────────────────────
                Section(header: Text("How much did you consume?")) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0", text: $inputText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                // ── Quick action ──────────────────────────────
                Section {
                    Button {
                        onSave(item.amountValue)
                    } label: {
                        Label("Consumed All (\(item.amountValue))", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Consumed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave(consumedAmount) }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationView {
        CurrentFoodListView(items: .constant(sampleItems), onItemSaved: { _ in })
    }
    .environment(ToBuyStore())
    .environment(FoodNameStore())
    .environment(FoodItemStore())
    .environment(ConsumptionStore())
}
