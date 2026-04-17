import Foundation

// MARK: - Consumption Record
//
// Stored whenever the user marks a food item as consumed.
// Contains enough info to identify the food and show it on the Insights tab.

struct ConsumptionRecord: Identifiable, Codable {
    var id:              UUID   = UUID()
    var foodName:        String
    var itemType:        String
    var storagePlace:    String
    var purchaseLocation: String  // empty if not set
    var amountConsumed:  Int
    var dateConsumed:    Date
}
