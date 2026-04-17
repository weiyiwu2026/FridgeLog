import Foundation
import Observation

// MARK: - Consumption Store
//
// Persists every consumption event so the Insights tab can show
// what was eaten, when, and how much.

@Observable class ConsumptionStore {

    var records: [ConsumptionRecord] = []
    private let storageKey = "consumptionRecords"

    init() {
        if let data  = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([ConsumptionRecord].self, from: data) {
            records = saved
        }
    }

    /// Adds a new consumption record and persists it.
    func add(_ record: ConsumptionRecord) {
        records.append(record)
        save()
    }

    /// Returns records from the last N days, most recent first.
    func recent(days: Int = 30) -> [ConsumptionRecord] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return records
            .filter { $0.dateConsumed >= cutoff }
            .sorted { $0.dateConsumed > $1.dateConsumed }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
