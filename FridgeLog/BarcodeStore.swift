import Foundation
import Observation

// MARK: - Barcode Record

/// A single saved barcode → food item mapping.
struct BarcodeRecord: Identifiable, Codable {
    var id           = UUID()
    var barcode:      String
    var name:         String
    var itemType:     String
    var storagePlace: String
    var shelfLifeDays: Int
}

// MARK: - Barcode Store

/// Persists user-learned barcode mappings locally in UserDefaults.
/// When the user manually enters an item after scanning an unknown barcode,
/// the mapping is saved here so future scans of the same code are pre-filled.

@Observable class BarcodeStore {

    var records: [BarcodeRecord] = []
    private let storageKey = "barcodeRecords"

    init() {
        if let data  = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([BarcodeRecord].self, from: data) {
            records = saved
        }
    }

    // MARK: - Lookup

    /// Returns the saved record for a barcode, or nil if not yet known.
    func record(for barcode: String) -> BarcodeRecord? {
        records.first { $0.barcode == barcode }
    }

    // MARK: - Save

    /// Saves or updates a barcode mapping.
    /// If the barcode already exists, the record is updated (e.g. user corrected the name).
    func save(_ record: BarcodeRecord) {
        if let index = records.firstIndex(where: { $0.barcode == record.barcode }) {
            records[index] = record
        } else {
            records.append(record)
        }
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
