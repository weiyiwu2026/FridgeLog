import Foundation

enum AmountType: String, CaseIterable {
    case quantity = "Quantity"
    case portions = "Portions"
}

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var amountType: AmountType      // either .quantity or .portions — never both
    var amountValue: Int            // the number, interpreted by amountType
    var storagePlace: String        // "Fridge", "Freezer", "Pantry"
    var itemType: String            // "Produce", "Meat", "Dairy", "Packaged", "Frozen", "Pantry", "Other"
    var purchaseDate: Date
    var estimatedShelfLifeDays: Int
    var expirationDate: Date?
}
