import SwiftUI

// MARK: - Insights Tab

struct InsightsView: View {

    @Environment(FoodItemStore.self)    private var foodItemStore
    @Environment(ToBuyStore.self)       private var toBuyStore
    @Environment(ConsumptionStore.self) private var consumptionStore

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

    private var recentRecords: [ConsumptionRecord] { consumptionStore.recent(days: 30) }
    private var consumedThisMonth: Int { recentRecords.reduce(0) { $0 + $1.amountConsumed } }

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

                // ── Consumption ───────────────────────────────
                Section("Consumption (Last 30 Days)") {
                    InsightRow(
                        label: "Items Consumed",
                        value: recentRecords.count,
                        icon:  "fork.knife",
                        color: .orange,
                        note:  recentRecords.isEmpty ? "None yet" : nil
                    )
                    InsightRow(
                        label: "Total Amount",
                        value: consumedThisMonth,
                        icon:  "chart.bar",
                        color: .orange,
                        note:  consumedThisMonth == 0 ? "None yet" : nil
                    )
                    if !recentRecords.isEmpty {
                        ForEach(recentRecords.prefix(5)) { record in
                            ConsumptionRow(record: record)
                        }
                    }
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

// MARK: - Consumption Row

struct ConsumptionRow: View {

    let record: ConsumptionRecord

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .foregroundColor(.orange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.foodName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(Self.dateFormatter.string(from: record.dateConsumed))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("×\(record.amountConsumed)")
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    InsightsView()
        .environment(FoodItemStore())
        .environment(ToBuyStore())
        .environment(ConsumptionStore())
}
