import Foundation
import Observation

// Represents one food entry (name + category + storage defaults).
// Used for both built-in foods (loaded from JSON) and user-added customs.
struct FoodEntry: Codable {
    let name: String
    let itemType: String
    let storagePlace: String
    let shelfLife: String   // e.g. "7 days"

    init(name: String, itemType: String, storagePlace: String = "Fridge", shelfLife: String = "7 days") {
        self.name = name
        self.itemType = itemType
        self.storagePlace = storagePlace
        self.shelfLife = shelfLife
    }

    // Backwards-compatible decoder: old custom entries lack storagePlace/shelfLife.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name         = try c.decode(String.self, forKey: .name)
        itemType     = try c.decode(String.self, forKey: .itemType)
        storagePlace = try c.decodeIfPresent(String.self, forKey: .storagePlace) ?? "Fridge"
        shelfLife    = try c.decodeIfPresent(String.self, forKey: .shelfLife)    ?? "7 days"
    }
}

// Matches the shape of each object in StandardFoods.json
private struct StandardFoodJSON: Decodable {
    let name: String
    let defaultItemType: String
    let defaultStoragePlace: String
    let defaultShelfLife: String
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
            builtInEntries = decoded.map {
                FoodEntry(name: $0.name, itemType: $0.defaultItemType,
                          storagePlace: $0.defaultStoragePlace, shelfLife: $0.defaultShelfLife)
            }
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

    // Returns the matching entry for a known name, or nil if unknown.
    private func entry(for name: String) -> FoodEntry? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return allEntries.first(where: { $0.name.lowercased() == trimmed.lowercased() })
    }

    // Returns the default item type for a known name, or nil if unknown.
    func defaultItemType(for name: String) -> String? { entry(for: name)?.itemType }

    // Returns the default storage place for a known name, or nil if unknown.
    func defaultStoragePlace(for name: String) -> String? { entry(for: name)?.storagePlace }

    // Returns the default shelf life in days for a known name, or nil if unknown.
    // Parses strings like "3 days" → 3, "2 weeks" → 14, "3 months" → 90, "1 year" → 365.
    func defaultShelfLifeDays(for name: String) -> Int? {
        guard let raw = entry(for: name)?.shelfLife else { return nil }
        let parts = raw.lowercased().components(separatedBy: " ")
        guard parts.count >= 2, let value = Int(parts[0]) else { return nil }
        switch parts[1] {
        case "day", "days":   return value
        case "week", "weeks": return value * 7
        case "month", "months": return value * 30
        case "year", "years": return value * 365
        default: return value
        }
    }

    // Adds a new entry to the custom list if the name does not already exist.
    func add(name: String, itemType: String, storagePlace: String, shelfLifeDays: Int) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !allEntries.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }
        let shelfLife = "\(shelfLifeDays) day\(shelfLifeDays == 1 ? "" : "s")"
        customEntries.append(FoodEntry(name: trimmed, itemType: itemType, storagePlace: storagePlace, shelfLife: shelfLife))
        if let data = try? JSONEncoder().encode(customEntries) {
            UserDefaults.standard.set(data, forKey: customStorageKey)
        }
    }
}
