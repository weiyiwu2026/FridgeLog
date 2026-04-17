import SwiftUI

struct ItemReviewView: View {

    let item: FoodItem
    let onSave: (FoodItem) -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        List {

            // ── Item Details ──────────────────────────────────
            Section(header: Text("Item Details")) {
                ReviewRow(label: "Name",         value: item.name)
                ReviewRow(label: "Item Type",    value: item.itemType)
                ReviewRow(label: "Storage",      value: item.storagePlace)
                if !item.purchaseLocation.isEmpty {
                    ReviewRow(label: "Bought At", value: item.purchaseLocation)
                }
            }

            // ── Amount ────────────────────────────────────────
            Section(header: Text("Amount")) {
                ReviewRow(label: item.amountType.rawValue, value: "\(item.amountValue)")
            }

            // ── Dates ─────────────────────────────────────────
            Section(header: Text("Dates")) {
                ReviewRow(label: "Purchase Date",
                          value: Self.dateFormatter.string(from: item.purchaseDate))
                ReviewRow(label: "Shelf Life",
                          value: "\(item.estimatedShelfLifeDays) day\(item.estimatedShelfLifeDays == 1 ? "" : "s")")
                ReviewRow(label: "Expiration Date",
                          value: Self.dateFormatter.string(from: item.expirationDate))
            }

            // ── Save ──────────────────────────────────────────
            Section {
                Button(action: { onSave(item) }) {
                    Text("Save Item")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Review Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Read-only row
struct ReviewRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationView {
        ItemReviewView(
            item: FoodItem(
                name: "Ground Beef", amountType: .portions, amountValue: 4,
                storagePlace: "Freezer", itemType: "Meat",
                purchaseDate: Date(), estimatedShelfLifeDays: 90,
                expirationDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
            ),
            onSave: { _ in }
        )
    }
}
