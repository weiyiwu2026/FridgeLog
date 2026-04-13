import SwiftUI

// MARK: - To Buy List Screen

struct ToBuyListView: View {

    @Environment(ToBuyStore.self)   private var toBuyStore
    @State private var showAddItem = false

    private var pendingItems: [ToBuyItem] { toBuyStore.items.filter { !$0.isBought  } }
    private var boughtItems:  [ToBuyItem] { toBuyStore.items.filter {  $0.isBought  } }

    var body: some View {
        Group {
            if toBuyStore.items.isEmpty {
                // ── Empty state ───────────────────────────────
                VStack(spacing: 16) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Your to buy list is empty.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Tap + to add your first item.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // ── Shopping list ─────────────────────────────
                List {

                    // Items still to buy
                    if !pendingItems.isEmpty {
                        Section("To Buy") {
                            ForEach(pendingItems) { item in
                                ToBuyRow(item: item)
                                    // Swipe right → mark as bought
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button { toBuyStore.toggleBought(item) } label: {
                                            Label("Bought", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(.green)
                                    }
                                    // Swipe left → delete
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            toBuyStore.delete(item: item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    // Already bought items
                    if !boughtItems.isEmpty {
                        Section {
                            ForEach(boughtItems) { item in
                                ToBuyRow(item: item)
                                    // Swipe right → undo bought
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button { toBuyStore.toggleBought(item) } label: {
                                            Label("Undo", systemImage: "arrow.uturn.left")
                                        }
                                        .tint(.orange)
                                    }
                                    // Swipe left → delete
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            toBuyStore.delete(item: item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            HStack {
                                Text("Bought")
                                Spacer()
                                Button("Clear All") { toBuyStore.clearBought() }
                                    .font(.caption)
                                    .textCase(nil)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("To Buy List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddItem = true }) {
                    Image(systemName: "plus").font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddToBuyItemView()
        }
    }
}

// MARK: - To Buy Row

struct ToBuyRow: View {
    let item: ToBuyItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            VStack(alignment: .leading, spacing: 3) {
                // Name — struck through when bought
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isBought, color: .secondary)
                    .foregroundColor(item.isBought ? .secondary : .primary)

                // Store and note on a second line (only if present)
                let hasStore = !item.store.isEmpty
                let hasNote  = !item.note.isEmpty
                if hasStore || hasNote {
                    HStack(spacing: 8) {
                        if hasStore {
                            Label(item.store, systemImage: "storefront")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if hasNote {
                            Text(item.note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            // Green checkmark badge when bought
            if item.isBought {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .imageScale(.large)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add To Buy Item Sheet

struct AddToBuyItemView: View {

    @Environment(\.dismiss)         private var dismiss
    @Environment(ToBuyStore.self)   private var toBuyStore
    @Environment(FoodNameStore.self) private var foodNameStore

    @State private var name  = ""
    @State private var store = ""
    @State private var note  = ""
    @State private var showNameError = false

    // Suggestions shown as the user types the item name.
    // Pulls from:  1) built-in and custom food names (via FoodNameStore)
    //              2) names the user has previously added to the buy list
    private var suggestions: [String] {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }

        let fromFood = foodNameStore.suggestions(for: trimmed).map { $0.name }

        let fromBuyList = toBuyStore.allItemNames.filter {
            $0.lowercased().contains(trimmed.lowercased()) &&
            $0.lowercased() != trimmed.lowercased()
        }

        return Array(Set(fromFood + fromBuyList))
            .sorted()
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationView {
            Form {

                // ── Item name + autocomplete ──────────────────
                Section(header: Text("Item")) {
                    TextField("Item name (e.g. Milk)", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) {
                            if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                                showNameError = false
                            }
                        }

                    if showNameError {
                        Text("Please enter an item name.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Autocomplete suggestion rows
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: { name = suggestion }) {
                            Label(suggestion, systemImage: "magnifyingglass")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }

                // ── Optional details ─────────────────────────
                Section(header: Text("Optional Details")) {
                    TextField("Store (e.g. Costco)", text: $store)
                    TextField("Note or quantity (e.g. 2 packs)", text: $note)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addItem() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addItem() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameError = true
            return
        }
        toBuyStore.add(ToBuyItem(
            name:  trimmed,
            store: store.trimmingCharacters(in: .whitespaces),
            note:  note.trimmingCharacters(in: .whitespaces)
        ))
        dismiss()
    }
}

#Preview {
    NavigationView {
        ToBuyListView()
    }
    .environment(ToBuyStore())
    .environment(FoodNameStore())
}
