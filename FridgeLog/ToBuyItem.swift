import Foundation

struct ToBuyItem: Identifiable, Codable {
    var id:       UUID
    var name:     String
    var store:    String   // empty = not set
    var note:     String   // empty = not set; free-text reminder
    var quantity: Int      // how many to buy; always >= 1
    var isBought:   Bool
    var purchaseDate: Date?   // set to Date() when marked bought; nil when un-marked

    init(name: String, store: String = "", note: String = "", quantity: Int = 1, isBought: Bool = false) {
        self.id           = UUID()
        self.name         = name
        self.store        = store
        self.note         = note
        self.quantity     = quantity
        self.isBought     = isBought
        self.purchaseDate = nil
    }

    // Custom decoder for backward compatibility with saves that predate
    // the "quantity" and "purchaseDate" fields.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(UUID.self,   forKey: .id)
        name         = try c.decode(String.self, forKey: .name)
        store        = try c.decode(String.self, forKey: .store)
        note         = try c.decode(String.self, forKey: .note)
        isBought     = try c.decode(Bool.self,   forKey: .isBought)
        quantity     = try c.decodeIfPresent(Int.self,  forKey: .quantity)     ?? 1
        purchaseDate = try c.decodeIfPresent(Date.self, forKey: .purchaseDate)
    }
}
