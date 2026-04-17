import Foundation
import Observation

// MARK: - Food Item Store
//
// Shared source of truth for the current food inventory.
// Injected at the app root so both HomeView and InsightsView
// can read and write the same item list.
// Items are persisted to UserDefaults so they survive app restarts.

@Observable class FoodItemStore {

    var items: [FoodItem] = []
    private let storageKey = "foodItems"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([FoodItem].self, from: data) {
            items = saved
        } else {
            // First launch — seed with sample data so the app isn't empty
            items = sampleItems
        }
    }

    /// Removes all food items.
    func clearAll() {
        items = []
        save()
    }

    /// Adds a new item, or increments the amount if an identical item already exists.
    func add(_ newItem: FoodItem) {
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
        save()
    }

    /// Deletes a single item by ID.
    func delete(_ item: FoodItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    /// Increments the quantity of an existing item by 1.
    func increment(_ item: FoodItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].amountValue += 1
        save()
    }

    /// Decrements the quantity by 1. Deletes the item if quantity reaches 0.
    func decrement(_ item: FoodItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].amountValue <= 1 {
            items.remove(at: index)
        } else {
            items[index].amountValue -= 1
        }
        save()
    }

    /// Subtracts `amount` from the item's quantity.
    /// If the result is 0 or less, the item is removed entirely.
    func consume(_ item: FoodItem, amount: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if amount >= items[index].amountValue {
            items.remove(at: index)
        } else {
            items[index].amountValue -= amount
        }
        save()
    }

    /// Replaces an existing item (matched by the given ID) with a new version.
    /// Used when saving edits made to an existing item.
    func replace(id: UUID, with newItem: FoodItem) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index] = newItem
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
