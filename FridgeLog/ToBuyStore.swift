import Foundation
import Observation

@Observable
class ToBuyStore {

    var items: [ToBuyItem] = []
    private let storageKey = "toBuyItems"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([ToBuyItem].self, from: data) {
            items = saved
        }
    }

    // Count of items not yet bought — used for the Home dashboard badge
    var pendingCount: Int { items.filter { !$0.isBought }.count }

    // All unique item names ever added — used for autocomplete suggestions
    var allItemNames: [String] {
        Array(Set(items.map { $0.name })).sorted()
    }

    // MARK: - Actions

    func add(_ item: ToBuyItem) {
        items.append(item)
        save()
    }

    /// Smart add from the My Food page.
    ///
    /// Matching rules (only among non-bought items):
    /// - If `store` is non-empty → match by name AND store (case-insensitive)
    /// - If `store` is empty    → match by name only
    ///
    /// If a match exists: increment its quantity by 1.
    /// If no match: create a new item with the given name and store.
    func addFromFood(name: String, store: String, quantity: Int) {
        let cleanName  = name.trimmingCharacters(in: .whitespaces)
        let cleanStore = store.trimmingCharacters(in: .whitespaces)
        let hasStore   = !cleanStore.isEmpty
        let qty        = max(1, quantity)

        if let index = items.firstIndex(where: { item in
            guard !item.isBought else { return false }
            let nameMatches = item.name.trimmingCharacters(in: .whitespaces)
                .caseInsensitiveCompare(cleanName) == .orderedSame
            if hasStore {
                let storeMatches = item.store.trimmingCharacters(in: .whitespaces)
                    .caseInsensitiveCompare(cleanStore) == .orderedSame
                return nameMatches && storeMatches
            } else {
                return nameMatches
            }
        }) {
            items[index].quantity += qty
        } else {
            items.append(ToBuyItem(name: cleanName, store: cleanStore, quantity: qty))
        }
        save()
    }

    func incrementQuantity(_ item: ToBuyItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
        save()
    }

    func decrementOrDeleteQuantity(_ item: ToBuyItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity <= 1 {
            items.remove(at: index)
        } else {
            items[index].quantity -= 1
        }
        save()
    }

    func delete(item: ToBuyItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func toggleBought(_ item: ToBuyItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isBought.toggle()
        save()
    }

    func clearBought() {
        items.removeAll { $0.isBought }
        save()
    }

    func clearAll() {
        items = []
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
