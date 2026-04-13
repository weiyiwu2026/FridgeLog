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

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
