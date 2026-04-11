import Foundation

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var storagePlace: String        // "Fridge", "Freezer", "Pantry"
    var itemType: String            // "Produce", "Meat", "Dairy", "Packaged", "Frozen", "Pantry", "Other"
    var purchaseDate: Date
    var estimatedShelfLifeDays: Int
    var expirationDate: Date?       // nil if the user did not enter one
}
