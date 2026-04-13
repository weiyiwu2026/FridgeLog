import SwiftUI

// MARK: - To Buy List Screen

struct ToBuyListView: View {

    @Environment(ToBuyStore.self)    private var toBuyStore
    @State private var showAddItem  = false

    // ── Selection mode state ─────────────────────────────────────
    @State private var isSelecting  = false
    @State private var selectedIDs: Set<UUID> = []

    private var pendingItems: [ToBuyItem] { toBuyStore.items.filter { !$0.isBought } }
    private var boughtItems:  [ToBuyItem] { toBuyStore.items.filter {  $0.isBought } }

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
                                selectableRow(for: item)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button { toBuyStore.toggleBought(item) } label: {
                                            Label("Bought", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(.green)
                                    }
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
                                selectableRow(for: item)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button { toBuyStore.toggleBought(item) } label: {
                                            Label("Undo", systemImage: "arrow.uturn.left")
                                        }
                                        .tint(.orange)
                                    }
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
        // ── Toolbar ───────────────────────────────────────────────
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // "+" is hidden during selection mode
                if !isSelecting {
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus").font(.title3)
                    }
                }
                // "Select" enters selection mode; "Done" exits it
                Button(isSelecting ? "Done" : "Select") {
                    if isSelecting { exitSelectionMode() } else { isSelecting = true }
                }
            }
        }
        // ── Bottom action bar (visible in selection mode only) ────
        .safeAreaInset(edge: .bottom) {
            if isSelecting {
                HStack(spacing: 12) {
                    // Mark as Bought
                    Button(action: markSelectedAsBought) {
                        Label("Mark Bought", systemImage: "checkmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedIDs.isEmpty ? Color(.systemGray5) : Color.green)
                            .foregroundColor(selectedIDs.isEmpty ? .secondary : .white)
                            .cornerRadius(12)
                    }
                    .disabled(selectedIDs.isEmpty)

                    // Remove
                    Button(action: removeSelected) {
                        Label("Remove", systemImage: "trash")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedIDs.isEmpty ? Color(.systemGray5) : Color.red)
                            .foregroundColor(selectedIDs.isEmpty ? .secondary : .white)
                            .cornerRadius(12)
                    }
                    .disabled(selectedIDs.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.regularMaterial)
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddToBuyItemView()
        }
    }

    // MARK: - Selectable Row

    // Wraps ToBuyRow with a leading circle/checkmark in selection mode.
    // Tapping the row toggles its selection when isSelecting is true.
    @ViewBuilder
    private func selectableRow(for item: ToBuyItem) -> some View {
        HStack(spacing: 12) {
            if isSelecting {
                Image(systemName: selectedIDs.contains(item.id)
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title3)
                    .foregroundColor(selectedIDs.contains(item.id) ? .accentColor : .secondary)
                    .animation(.easeInOut(duration: 0.15), value: selectedIDs.contains(item.id))
            }
            ToBuyRow(item: item)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelecting { toggleSelection(item) }
        }
    }

    // MARK: - Selection Helpers

    private func toggleSelection(_ item: ToBuyItem) {
        if selectedIDs.contains(item.id) {
            selectedIDs.remove(item.id)
        } else {
            selectedIDs.insert(item.id)
        }
    }

    // Mark all selected items as bought (silently skips items already bought).
    // Exits selection mode after — the user has completed their action.
    private func markSelectedAsBought() {
        for id in selectedIDs {
            if let item = toBuyStore.items.first(where: { $0.id == id }), !item.isBought {
                toBuyStore.toggleBought(item)
            }
        }
        exitSelectionMode()
    }

    // Delete all selected items.
    // Exits selection mode after — the user has completed their action.
    private func removeSelected() {
        for id in selectedIDs {
            if let item = toBuyStore.items.first(where: { $0.id == id }) {
                toBuyStore.delete(item: item)
            }
        }
        exitSelectionMode()
    }

    // Clears selected IDs and leaves selection mode.
    private func exitSelectionMode() {
        isSelecting = false
        selectedIDs.removeAll()
    }
}

// MARK: - To Buy Row

struct ToBuyRow: View {
    let item: ToBuyItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isBought, color: .secondary)
                    .foregroundColor(item.isBought ? .secondary : .primary)

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

    @Environment(\.dismiss)          private var dismiss
    @Environment(ToBuyStore.self)    private var toBuyStore
    @Environment(FoodNameStore.self) private var foodNameStore

    @State private var name  = ""
    @State private var store = ""
    @State private var note  = ""
    @State private var showNameError = false

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

                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: { name = suggestion }) {
                            Label(suggestion, systemImage: "magnifyingglass")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }

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
