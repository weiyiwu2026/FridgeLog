import SwiftUI

struct ManualEntryView: View {

    // Called when the user taps Save with a valid item
    let onSave: (FoodItem) -> Void

    @Environment(\.dismiss) private var dismiss

    // Form fields
    @State private var name                = ""
    @State private var quantity            = 1
    @State private var storagePlace        = "Fridge"
    @State private var itemType            = "Other"
    @State private var purchaseDate        = Date()
    @State private var shelfLifeDays       = 7
    @State private var hasExpirationDate   = false
    @State private var expirationDate      = Date()

    @State private var showNameError       = false

    let storagePlaces = ["Fridge", "Freezer", "Pantry"]
    let itemTypes     = ["Produce", "Meat", "Dairy", "Packaged", "Frozen", "Pantry", "Other"]

    var body: some View {
        Form {

            // ── Item Details ──────────────────────────────────
            Section(header: Text("Item Details")) {
                TextField("Item name (e.g. Milk)", text: $name)
                    .autocorrectionDisabled()
                    .onChange(of: name) { _ in
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                            showNameError = false
                        }
                    }

                if showNameError {
                    Text("Please enter an item name.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Picker("Item Type", selection: $itemType) {
                    ForEach(itemTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }

                Picker("Storage Place", selection: $storagePlace) {
                    ForEach(storagePlaces, id: \.self) { place in
                        Text(place).tag(place)
                    }
                }
            }

            // ── Quantity ──────────────────────────────────────
            Section(header: Text("Quantity")) {
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
            }

            // ── Dates ─────────────────────────────────────────
            Section(header: Text("Dates")) {
                DatePicker(
                    "Purchase Date",
                    selection: $purchaseDate,
                    displayedComponents: .date
                )

                Stepper(
                    "Shelf Life: \(shelfLifeDays) day\(shelfLifeDays == 1 ? "" : "s")",
                    value: $shelfLifeDays,
                    in: 1...365
                )

                Toggle("Enter Exact Expiration Date", isOn: $hasExpirationDate)

                if hasExpirationDate {
                    DatePicker(
                        "Expiration Date",
                        selection: $expirationDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
            }
        }
        .navigationTitle("Manual Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveItem()
                }
                .fontWeight(.semibold)
            }
        }
    }

    // ── Save Logic ────────────────────────────────────────────
    private func saveItem() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameError = true
            return
        }

        let newItem = FoodItem(
            name: trimmed,
            quantity: quantity,
            storagePlace: storagePlace,
            itemType: itemType,
            purchaseDate: purchaseDate,
            estimatedShelfLifeDays: shelfLifeDays,
            expirationDate: hasExpirationDate ? expirationDate : nil
        )

        onSave(newItem)   // adds item to the list and closes the sheet
    }
}

#Preview {
    NavigationView {
        ManualEntryView(onSave: { _ in })
    }
}
