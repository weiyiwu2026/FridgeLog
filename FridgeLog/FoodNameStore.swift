import Foundation
import Observation

struct FoodEntry: Codable {
    let name: String
    let itemType: String
}

@Observable
class FoodNameStore {

    private(set) var entries: [FoodEntry]

    private let storageKey = "standardFoodEntries"

    static let defaultEntries: [FoodEntry] = [
        // Produce
        FoodEntry(name: "Apple",          itemType: "Produce"),
        FoodEntry(name: "Banana",         itemType: "Produce"),
        FoodEntry(name: "Orange",         itemType: "Produce"),
        FoodEntry(name: "Grapes",         itemType: "Produce"),
        FoodEntry(name: "Strawberries",   itemType: "Produce"),
        FoodEntry(name: "Blueberries",    itemType: "Produce"),
        FoodEntry(name: "Avocado",        itemType: "Produce"),
        FoodEntry(name: "Tomato",         itemType: "Produce"),
        FoodEntry(name: "Lemon",          itemType: "Produce"),
        FoodEntry(name: "Broccoli",       itemType: "Produce"),
        FoodEntry(name: "Carrots",        itemType: "Produce"),
        FoodEntry(name: "Spinach",        itemType: "Produce"),
        FoodEntry(name: "Kale",           itemType: "Produce"),
        FoodEntry(name: "Onion",          itemType: "Produce"),
        FoodEntry(name: "Garlic",         itemType: "Produce"),
        FoodEntry(name: "Potatoes",       itemType: "Produce"),
        FoodEntry(name: "Sweet Potatoes", itemType: "Produce"),
        FoodEntry(name: "Bell Pepper",    itemType: "Produce"),
        FoodEntry(name: "Cucumber",       itemType: "Produce"),
        FoodEntry(name: "Zucchini",       itemType: "Produce"),
        FoodEntry(name: "Eggs",           itemType: "Produce"),
        // Dairy
        FoodEntry(name: "Milk",           itemType: "Dairy"),
        FoodEntry(name: "Butter",         itemType: "Dairy"),
        FoodEntry(name: "Cheese",         itemType: "Dairy"),
        FoodEntry(name: "Yogurt",         itemType: "Dairy"),
        FoodEntry(name: "Cream",          itemType: "Dairy"),
        FoodEntry(name: "Sour Cream",     itemType: "Dairy"),
        // Meat
        FoodEntry(name: "Chicken Breast", itemType: "Meat"),
        FoodEntry(name: "Ground Beef",    itemType: "Meat"),
        FoodEntry(name: "Pork Chops",     itemType: "Meat"),
        FoodEntry(name: "Bacon",          itemType: "Meat"),
        FoodEntry(name: "Salmon",         itemType: "Meat"),
        FoodEntry(name: "Tuna",           itemType: "Meat"),
        FoodEntry(name: "Shrimp",         itemType: "Meat"),
        FoodEntry(name: "Turkey",         itemType: "Meat"),
        // Frozen
        FoodEntry(name: "Frozen Peas",    itemType: "Frozen"),
        FoodEntry(name: "Frozen Corn",    itemType: "Frozen"),
        FoodEntry(name: "Frozen Berries", itemType: "Frozen"),
        // Pantry
        FoodEntry(name: "Rice",           itemType: "Pantry"),
        FoodEntry(name: "Pasta",          itemType: "Pantry"),
        FoodEntry(name: "Bread",          itemType: "Pantry"),
        FoodEntry(name: "Oats",           itemType: "Pantry"),
        FoodEntry(name: "Flour",          itemType: "Pantry"),
        FoodEntry(name: "Tortillas",      itemType: "Pantry"),
        FoodEntry(name: "Olive Oil",      itemType: "Pantry"),
        FoodEntry(name: "Soy Sauce",      itemType: "Pantry"),
        FoodEntry(name: "Hot Sauce",      itemType: "Pantry"),
        FoodEntry(name: "Ketchup",        itemType: "Pantry"),
        FoodEntry(name: "Mustard",        itemType: "Pantry"),
        FoodEntry(name: "Orange Juice",   itemType: "Pantry"),
        FoodEntry(name: "Apple Juice",    itemType: "Pantry"),
        FoodEntry(name: "Canned Beans",   itemType: "Pantry"),
        FoodEntry(name: "Canned Tomatoes",itemType: "Pantry"),
        FoodEntry(name: "Canned Tuna",    itemType: "Pantry"),
        FoodEntry(name: "Sugar",          itemType: "Pantry"),
        FoodEntry(name: "Salt",           itemType: "Pantry"),
        FoodEntry(name: "Black Pepper",   itemType: "Pantry"),
        // Packaged
        FoodEntry(name: "Cereal",         itemType: "Packaged"),
        FoodEntry(name: "Granola Bars",   itemType: "Packaged"),
        FoodEntry(name: "Crackers",       itemType: "Packaged"),
        FoodEntry(name: "Chips",          itemType: "Packaged"),
    ]

    init() {
        if let data = UserDefaults.standard.data(forKey: "standardFoodEntries"),
           let saved = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            entries = saved
        } else {
            entries = Self.defaultEntries
        }
    }

    // Returns up to 5 entries whose name partially matches the query.
    // Returns empty if query is blank or already exactly matches a known name.
    func suggestions(for query: String) -> [FoodEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        if entries.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            return []
        }
        return Array(
            entries
                .filter { $0.name.lowercased().contains(trimmed.lowercased()) }
                .prefix(5)
        )
    }

    // Returns the default item type for a known name, or nil if unknown.
    func defaultItemType(for name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return entries.first(where: { $0.name.lowercased() == trimmed.lowercased() })?.itemType
    }

    // Adds a new entry if the name doesn't already exist (case-insensitive).
    func add(name: String, itemType: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !entries.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }
        entries.append(FoodEntry(name: trimmed, itemType: itemType))
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
