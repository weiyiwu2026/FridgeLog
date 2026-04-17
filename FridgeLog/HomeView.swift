import SwiftUI

struct HomeView: View {

    @Environment(FoodNameStore.self)  private var foodNameStore
    @Environment(ToBuyStore.self)    private var toBuyStore
    @Environment(FoodItemStore.self) private var foodItemStore
    @State private var showAddItem = false

    // Number of items expiring within the next 7 days — used as a live badge
    private var expiringSoonCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return foodItemStore.items.filter { $0.expirationDate <= cutoff }.count
    }

    var body: some View {
        @Bindable var store = foodItemStore
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
                            CurrentFoodListView(items: $store.items, onItemSaved: saveItem)
                        ) {
                            DashboardCard(
                                title: "My Food",
                                icon: "refrigerator",
                                badge: "\(foodItemStore.items.count) item\(foodItemStore.items.count == 1 ? "" : "s")"
                            )
                        }
                        .buttonStyle(.plain)

                        // Card 2 – Expiring Soon
                        NavigationLink(destination:
                            ExpiringSoonView(items: foodItemStore.items)
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

                        // Card 3 – To Buy List
                        NavigationLink(destination: ToBuyListView()) {
                            DashboardCard(
                                title: "Shopping List",
                                icon: "cart",
                                badge: toBuyStore.pendingCount > 0
                                    ? "\(toBuyStore.pendingCount) item\(toBuyStore.pendingCount == 1 ? "" : "s")"
                                    : "Empty"
                            )
                        }
                        .buttonStyle(.plain)

                        // Card 4 – What to Eat Today
                        NavigationLink(destination:
                            FoodIdeasView(items: foodItemStore.items)
                        ) {
                            DashboardCard(
                                title: "Meal Ideas",
                                icon: "fork.knife",
                                badge: {
                                        let n = generateIdeas(from: foodItemStore.items).count
                                        return "\(n) idea\(n == 1 ? "" : "s")"
                                    }()
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
            .navigationTitle("FoodLog")
            .sheet(isPresented: $showAddItem) {
                AddItemMethodView(onItemSaved: { newItem in
                    saveItem(newItem)
                    showAddItem = false
                })
            }
        }
    }

    // MARK: - Save / Delete Logic (shared by dashboard Add Item and FoodListView)

    func saveItem(_ newItem: FoodItem) {
        foodNameStore.add(
            name: newItem.name,
            itemType: newItem.itemType,
            storagePlace: newItem.storagePlace,
            shelfLifeDays: newItem.estimatedShelfLifeDays
        )
        foodItemStore.add(newItem)
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
        .environment(ToBuyStore())
        .environment(FoodItemStore())
}
