import SwiftUI

struct HomeView: View {

    @Environment(FoodNameStore.self) private var foodNameStore
    @State private var items: [FoodItem] = sampleItems
    @State private var showAddItem = false

    // Number of items expiring within the next 7 days — used as a live badge
    private var expiringSoonCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return items.filter { $0.expirationDate <= cutoff }.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // ── 2 × 2 Dashboard Grid ──────────────────────
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        // Card 1 – Current Food List (navigates to real inventory)
                        NavigationLink(destination:
                            CurrentFoodListView(items: $items, onItemSaved: saveItem)
                        ) {
                            DashboardCard(
                                title: "Current Food List",
                                icon: "refrigerator",
                                badge: "\(items.count) item\(items.count == 1 ? "" : "s")"
                            )
                        }
                        .buttonStyle(.plain)

                        // Card 2 – Expiring Soon
                        NavigationLink(destination:
                            ExpiringSoonView(items: items)
                        ) {
                            DashboardCard(
                                title: "Expiring Soon",
                                icon: "clock",
                                badge: expiringSoonCount > 0
                                    ? "\(expiringSoonCount) item\(expiringSoonCount == 1 ? "" : "s")"
                                    : "All good"
                            )
                        }
                        .buttonStyle(.plain)

                        // Card 3 – To Buy List (placeholder for now)
                        NavigationLink(destination:
                            PlaceholderView(title: "To Buy List")
                        ) {
                            DashboardCard(
                                title: "To Buy List",
                                icon: "cart",
                                badge: "Coming soon"
                            )
                        }
                        .buttonStyle(.plain)

                        // Card 4 – What to Eat Today (placeholder for now)
                        NavigationLink(destination:
                            PlaceholderView(title: "What to Eat Today")
                        ) {
                            DashboardCard(
                                title: "What to Eat Today",
                                icon: "fork.knife",
                                badge: "Coming soon"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // ── Add Item Button ───────────────────────────
                    Button(action: { showAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                }
                .padding()
            }
            .navigationTitle("FridgeLog")
            .sheet(isPresented: $showAddItem) {
                AddItemMethodView(onItemSaved: { newItem in
                    saveItem(newItem)
                    showAddItem = false
                })
            }
        }
    }

    // MARK: - Save Logic (shared by dashboard Add Item and FoodListView)

    func saveItem(_ newItem: FoodItem) {
        foodNameStore.add(
            name: newItem.name,
            itemType: newItem.itemType,
            storagePlace: newItem.storagePlace,
            shelfLifeDays: newItem.estimatedShelfLifeDays
        )
        if let index = items.firstIndex(where: {
            $0.name.lowercased() == newItem.name.lowercased() &&
            $0.storagePlace      == newItem.storagePlace &&
            $0.itemType          == newItem.itemType &&
            $0.amountType        == newItem.amountType &&
            Calendar.current.isDate($0.expirationDate, inSameDayAs: newItem.expirationDate)
        }) {
            items[index].amountValue += newItem.amountValue
        } else {
            items.append(newItem)
        }
    }
}

// MARK: - Dashboard Card

struct DashboardCard: View {
    let title: String
    let icon: String
    let badge: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(badge)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Sample Data

private func sampleExpiry(_ days: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
}

let sampleItems: [FoodItem] = [
    FoodItem(name: "Milk",        amountType: .quantity, amountValue: 1,  storagePlace: "Fridge",  itemType: "Dairy & Eggs",   purchaseDate: Date(), estimatedShelfLifeDays: 7,   expirationDate: sampleExpiry(7)),
    FoodItem(name: "Eggs",        amountType: .quantity, amountValue: 12, storagePlace: "Fridge",  itemType: "Dairy & Eggs",   purchaseDate: Date(), estimatedShelfLifeDays: 21,  expirationDate: sampleExpiry(21)),
    FoodItem(name: "Frozen Peas", amountType: .quantity, amountValue: 1,  storagePlace: "Freezer", itemType: "Frozen",         purchaseDate: Date(), estimatedShelfLifeDays: 90,  expirationDate: sampleExpiry(90)),
    FoodItem(name: "Ground Beef", amountType: .portions, amountValue: 4,  storagePlace: "Freezer", itemType: "Meat & Seafood", purchaseDate: Date(), estimatedShelfLifeDays: 120, expirationDate: sampleExpiry(120)),
    FoodItem(name: "Rice",        amountType: .quantity, amountValue: 2,  storagePlace: "Pantry",  itemType: "Pantry",         purchaseDate: Date(), estimatedShelfLifeDays: 365, expirationDate: sampleExpiry(365)),
]

#Preview {
    HomeView()
        .environment(FoodNameStore())
}
