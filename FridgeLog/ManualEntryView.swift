import SwiftUI

struct ManualEntryView: View {

    let onSave: (FoodItem) -> Void

    @Environment(FoodNameStore.self) private var foodNameStore
    @Environment(\.dismiss) private var dismiss

    @State private var name               = ""
    @State private var amountType         = AmountType.quantity
    @State private var amountValue        = 1
    @State private var storagePlace       = "Fridge"
    @State private var itemType           = ""      // empty = not yet chosen
    @State private var purchaseDate       = Date()
    @State private var shelfLifeDays      = 7
    @State private var hasExpirationDate  = false
    @State private var expirationDate     = Date()

    @State private var showNameError      = false
    @State private var showItemTypeError  = false
    @State private var showReview         = false
    @State private var reviewItem         = FoodItem(
        name: "", amountType: .quantity, amountValue: 1,
        storagePlace: "Fridge", itemType: "Other",
        purchaseDate: Date(), estimatedShelfLifeDays: 7, expirationDate: nil
    )

    let storagePlaces = ["Fridge", "Freezer", "Pantry"]
    let itemTypes     = ["Produce", "Dairy & Eggs", "Meat & Seafood", "Frozen", "Pantry", "Snacks", "Beverages", "Bakery", "Deli & Prepared", "Other"]

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var isKnownItem: Bool {
        foodNameStore.defaultItemType(for: trimmedName) != nil
    }

    private var showNewItemHint: Bool {
        !trimmedName.isEmpty && !isKnownItem && foodNameStore.suggestions(for: trimmedName).isEmpty
    }

    var body: some View {
        Form {

            // ── Item Details ──────────────────────────────────
            Section(header: Text("Item Details")) {
                TextField("Item name (e.g. Milk)", text: $name)
                    .autocorrectionDisabled()
                    .onChange(of: name) { _ in
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty { showNameError = false }

                        if let defaultType = foodNameStore.defaultItemType(for: trimmed) {
                            // Known item — auto-fill type
                            itemType = defaultType
                            showItemTypeError = false
                        } else {
                            // Unknown item — clear type so user must choose
                            itemType = ""
                        }
                    }

                if showNameError {
                    Text("Please enter an item name.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Autocomplete suggestions (optional — user can ignore these)
                ForEach(foodNameStore.suggestions(for: name), id: \.name) { entry in
                    Button(action: {
                        name = entry.name
                        itemType = entry.itemType
                        showItemTypeError = false
                    }) {
                        Label(entry.name, systemImage: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }

                // New item hint — shown only when name is typed but not in standard list
                if showNewItemHint {
                    Text("\"\(trimmedName)\" is a new item. Please choose an item type below.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Item type picker
                Picker("Item Type", selection: $itemType) {
                    if itemType.isEmpty {
                        Text("Select type...").tag("")
                    }
                    ForEach(itemTypes, id: \.self) { Text($0).tag($0) }
                }
                .onChange(of: itemType) { _ in
                    showItemTypeError = false
                }

                if showItemTypeError {
                    Text("Please select an item type.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Picker("Storage Place", selection: $storagePlace) {
                    ForEach(storagePlaces, id: \.self) { Text($0).tag($0) }
                }
            }

            // ── Amount ────────────────────────────────────────
            Section(header: Text("Amount")) {
                Picker("Amount Type", selection: $amountType) {
                    ForEach(AmountType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Stepper("\(amountType.rawValue): \(amountValue)", value: $amountValue, in: 1...99)
            }

            // ── Dates ─────────────────────────────────────────
            Section(header: Text("Dates")) {
                DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)

                Stepper(
                    "Shelf Life: \(shelfLifeDays) day\(shelfLifeDays == 1 ? "" : "s")",
                    value: $shelfLifeDays, in: 1...365
                )

                Toggle("Enter Exact Expiration Date", isOn: $hasExpirationDate)

                if hasExpirationDate {
                    DatePicker("Expiration Date", selection: $expirationDate,
                               in: Date()..., displayedComponents: .date)
                }
            }
        }
        .background(
            NavigationLink(
                destination: ItemReviewView(item: reviewItem, onSave: { savedItem in
                    onSave(savedItem)
                }),
                isActive: $showReview
            ) { EmptyView() }
        )
        .navigationTitle("Manual Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next") { goToReview() }
                    .fontWeight(.semibold)
            }
        }
    }

    private func goToReview() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameError = true
            return
        }
        guard !itemType.isEmpty else {
            showItemTypeError = true
            return
        }
        showNameError = false
        showItemTypeError = false
        reviewItem = FoodItem(
            name: trimmed,
            amountType: amountType,
            amountValue: amountValue,
            storagePlace: storagePlace,
            itemType: itemType,
            purchaseDate: purchaseDate,
            estimatedShelfLifeDays: shelfLifeDays,
            expirationDate: hasExpirationDate ? expirationDate : nil
        )
        showReview = true
    }
}

#Preview {
    NavigationView {
        ManualEntryView(onSave: { _ in })
    }
}
