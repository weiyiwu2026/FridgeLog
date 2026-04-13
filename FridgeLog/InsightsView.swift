import SwiftUI

// MARK: - Insights Tab

struct InsightsView: View {

    @Environment(FoodItemStore.self) private var foodItemStore
    @Environment(ToBuyStore.self)    private var toBuyStore

    // ── Computed summaries ────────────────────────────────────

    private var totalItems:   Int { foodItemStore.items.count }
    private var fridgeCount:  Int { foodItemStore.items.filter { $0.storagePlace == "Fridge"  }.count }
    private var freezerCount: Int { foodItemStore.items.filter { $0.storagePlace == "Freezer" }.count }
    private var pantryCount:  Int { foodItemStore.items.filter { $0.storagePlace == "Pantry"  }.count }

    private var expiringSoonCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return foodItemStore.items.filter { $0.expirationDate <= cutoff }.count
    }

    private var toBuyPendingCount: Int { toBuyStore.pendingCount }
    private var toBuyBoughtCount:  Int { toBuyStore.items.count - toBuyStore.pendingCount }

    private var ideasCount: Int {
        generateIdeas(from: foodItemStore.items).count
    }

    // ── View ──────────────────────────────────────────────────

    var body: some View {
        NavigationView {
            List {

                // ── Inventory ─────────────────────────────────
                Section("Inventory") {
                    InsightRow(
                        label: "Total Saved Items",
                        value: totalItems,
                        icon:  "tray.full",
                        color: .blue
                    )
                    InsightRow(
                        label: "In Fridge",
                        value: fridgeCount,
                        icon:  "refrigerator",
                        color: .cyan
                    )
                    InsightRow(
                        label: "In Freezer",
                        value: freezerCount,
                        icon:  "snowflake",
                        color: .indigo
                    )
                    InsightRow(
                        label: "In Pantry",
                        value: pantryCount,
                        icon:  "archivebox",
                        color: .brown
                    )
                }

                // ── Alerts ────────────────────────────────────
                Section("Alerts") {
                    InsightRow(
                        label: "Expiring Within 7 Days",
                        value: expiringSoonCount,
                        icon:  "clock",
                        color: expiringSoonCount > 0 ? .orange : .green,
                        note:  expiringSoonCount == 0 ? "All good" : nil
                    )
                }

                // ── Shopping ──────────────────────────────────
                Section("Shopping") {
                    InsightRow(
                        label: "Still to Buy",
                        value: toBuyPendingCount,
                        icon:  "cart.badge.plus",
                        color: .teal
                    )
                    InsightRow(
                        label: "Already Bought",
                        value: toBuyBoughtCount,
                        icon:  "checkmark.circle",
                        color: .green
                    )
                }

                // ── Ideas ─────────────────────────────────────
                Section("Food Ideas") {
                    InsightRow(
                        label: "Ideas Available",
                        value: ideasCount,
                        icon:  "fork.knife",
                        color: .purple,
                        note:  ideasCount == 0 ? "Add more items for ideas" : nil
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Insights")
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let label: String
    let value: Int
    let icon:  String
    let color: Color
    var note:  String? = nil   // optional small note shown instead of plain zero

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)

            Text(label)
                .foregroundColor(.primary)

            Spacer()

            if let note = note, value == 0 {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("\(value)")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    InsightsView()
        .environment(FoodItemStore())
        .environment(ToBuyStore())
}
