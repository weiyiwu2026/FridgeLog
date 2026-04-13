import SwiftUI

// MARK: - Food Item Store
//
// Shared source of truth for the current food inventory.
// Injected at the app root so both HomeView and InsightsView
// can read and write the same item list.

@Observable class FoodItemStore {

    var items: [FoodItem] = sampleItems

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
    }
}
