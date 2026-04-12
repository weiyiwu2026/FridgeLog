import Foundation
import Observation

// Represents one food entry (name + category).
// Used for both built-in foods (loaded from JSON) and user-added customs.
struct FoodEntry: Codable {
    let name: String
    let itemType: String
}

// Matches the shape of each object in StandardFoods.json
private struct StandardFoodJSON: Decodable {
    let name: String
    let defaultItemType: String
}

@Observable
class FoodNameStore {

    // Built-in foods loaded from StandardFoods.json (never modified at runtime)
    private let builtInEntries: [FoodEntry]

    // Foods the user has added themselves (persisted in UserDefaults)
    private(set) var customEntries: [FoodEntry]

    private let customStorageKey = "customFoodEntries"

    // All entries available for autocomplete (built-in + custom, built-in first)
    private var allEntries: [FoodEntry] {
        builtInEntries + customEntries
    }

    init() {
        // Load built-in list from the bundled JSON file
        if let url = Bundle.main.url(forResource: "StandardFoods", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([StandardFoodJSON].self, from: data) {
            builtInEntries = decoded.map { FoodEntry(name: $0.name, itemType: $0.defaultItemType) }
        } else {
            builtInEntries = []
        }

        // Load user-added custom foods from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "customFoodEntries"),
           let saved = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            customEntries = saved
        } else {
            customEntries = []
        }
    }

    // Returns up to 5 entries whose name partially matches the query.
    // Returns empty if query is blank or already exactly matches a known name.
    func suggestions(for query: String) -> [FoodEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        if allEntries.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            return []
        }
        return Array(
            allEntries
                .filter { $0.name.lowercased().contains(trimmed.lowercased()) }
                .prefix(5)
        )
    }

    // Returns the default item type for a known name, or nil if unknown.
    func defaultItemType(for name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return allEntries.first(where: { $0.name.lowercased() == trimmed.lowercased() })?.itemType
    }

    // Adds a new entry to the custom list if the name does not already exist.
    func add(name: String, itemType: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !allEntries.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }
        customEntries.append(FoodEntry(name: trimmed, itemType: itemType))
        if let data = try? JSONEncoder().encode(customEntries) {
            UserDefaults.standard.set(data, forKey: customStorageKey)
        }
    }
}
