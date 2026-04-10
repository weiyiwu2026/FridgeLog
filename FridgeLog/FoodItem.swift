import Foundation

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var amount: String
    var storagePlace: String  // "Fridge", "Freezer", or "Pantry"
}
