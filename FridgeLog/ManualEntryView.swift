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
    @State private var expirationDate     = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var purchaseLocation   = ""

    @State private var showNameError      = false
    @State private var showItemTypeError  = false
    @State private var showReview         = false
    @State private var reviewItem         = FoodItem(
        name: "", amountType: .quantity, amountValue: 1,
        storagePlace: "Fridge", itemType: "Other",
        purchaseDate: Date(), estimatedShelfLifeDays: 7,
        expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    )

    // When true, a Cancel button is shown in the nav bar (used when the form
    // is presented as a sheet rather than pushed onto a navigation stack).
    var showCancelButton: Bool = false

    // Designated init used by barcode scanner to pre-fill the form.
    // All parameters have defaults so existing call sites are unchanged.
    init(onSave: @escaping (FoodItem) -> Void, prefill: FoodItem? = nil, showCancelButton: Bool = false) {
        self.onSave = onSave
        self.showCancelButton = showCancelButton
        if let p = prefill {
            _name           = State(initialValue: p.name)
            _amountType     = State(initialValue: p.amountType)
            _amountValue    = State(initialValue: p.amountValue)
            _storagePlace   = State(initialValue: p.storagePlace)
            _itemType       = State(initialValue: p.itemType)
            _purchaseDate   = State(initialValue: p.purchaseDate)
            _shelfLifeDays      = State(initialValue: p.estimatedShelfLifeDays)
            _expirationDate     = State(initialValue: p.expirationDate)
            _purchaseLocation   = State(initialValue: p.purchaseLocation)
        }
    }

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

    private var locationSuggestions: [String] {
        guard !purchaseLocation.isEmpty else { return [] }
        return knownStores.filter {
            $0.localizedCaseInsensitiveContains(purchaseLocation)
        }
    }

    var body: some View {
        Form {

            // ── Item Details ──────────────────────────────────
            Section(header: Text("Item Details")) {
                TextField("Item name (e.g. Milk)", text: $name)
                    .autocorrectionDisabled()
                    .onChange(of: name) {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty { showNameError = false }

                        if let defaultType = foodNameStore.defaultItemType(for: trimmed) {
                            // Known item — auto-fill type, storage place, and shelf life
                            itemType = defaultType
                            showItemTypeError = false
                            if let place = foodNameStore.defaultStoragePlace(for: trimmed) {
                                storagePlace = place
                            }
                            if let days = foodNameStore.defaultShelfLifeDays(for: trimmed) {
                                shelfLifeDays = days
                            }
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
                        storagePlace = entry.storagePlace
                        if let days = foodNameStore.defaultShelfLifeDays(for: entry.name) {
                            shelfLifeDays = days
                        }
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
                .onChange(of: itemType) {
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

                HStack {
                    Text(amountType.rawValue)
                    Spacer()
                    TextField("1", value: $amountValue, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            // ── Purchase Location ─────────────────────────────
            Section(header: Text("Purchase Location")) {
                TextField("Store name (optional)", text: $purchaseLocation)
                    .autocorrectionDisabled()

                ForEach(locationSuggestions, id: \.self) { store in
                    Button(action: { purchaseLocation = store }) {
                        Label(store, systemImage: "storefront")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }

            // ── Dates ─────────────────────────────────────────
            // These three values are always kept in sync:
            //   expirationDate = purchaseDate + shelfLifeDays
            //   shelfLifeDays  = days from purchaseDate to expirationDate
            Section(header: Text("Dates")) {
                DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    .onChange(of: purchaseDate) {
                        expirationDate = Calendar.current.date(byAdding: .day, value: shelfLifeDays, to: purchaseDate) ?? purchaseDate
                    }

                HStack {
                    Text("Shelf Life (days)")
                    Spacer()
                    TextField("7", value: $shelfLifeDays, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                .onChange(of: shelfLifeDays) {
                    expirationDate = Calendar.current.date(byAdding: .day, value: shelfLifeDays, to: purchaseDate) ?? purchaseDate
                }

                DatePicker("Expiration Date", selection: $expirationDate,
                           in: purchaseDate..., displayedComponents: .date)
                    .onChange(of: expirationDate) {
                        let days = Calendar.current.dateComponents([.day], from: purchaseDate, to: expirationDate).day ?? 1
                        shelfLifeDays = max(1, days)
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
            if showCancelButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
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
            expirationDate: expirationDate,
            purchaseLocation: purchaseLocation.trimmingCharacters(in: .whitespaces)
        )
        showReview = true
    }
}

// MARK: - Known Stores for Purchase Location autofill

private let knownStores: [String] = [
    "Walmart", "Kroger", "Costco", "Albertsons", "Ahold Delhaize",
    "Publix", "Aldi", "Trader Joe's", "Target", "Sam's Club",
    "BJ's Wholesale Club", "H-E-B", "Meijer", "Hy-Vee", "Wegmans",
    "WinCo Foods", "Giant Eagle", "ShopRite", "Safeway", "Stop & Shop",
    "Food Lion", "Hannaford", "Whole Foods Market", "Sprouts Farmers Market",
    "Natural Grocers", "Fresh Market", "Grocery Outlet", "Save A Lot",
    "Loblaw Companies", "Real Canadian Superstore", "No Frills",
    "Shoppers Drug Mart", "Metro", "Sobeys", "Safeway Canada", "IGA",
    "Food Basics", "Longo's", "Farm Boy", "Save-On-Foods", "FreshCo", "Co-op",
    "H Mart", "99 Ranch Market", "Mitsuwa Marketplace", "Marukai",
    "Tokyo Central", "Uwajimaya", "Zion Market", "Patel Brothers",
    "Apna Bazaar", "T&T Supermarket",
]

#Preview {
    NavigationView {
        ManualEntryView(onSave: { _ in })
    }
}
