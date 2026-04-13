import Foundation

struct ToBuyItem: Identifiable, Codable {
    var id      = UUID()
    var name:   String
    var store:  String   // empty = not set
    var note:   String   // empty = not set; used for quantity or a reminder
    var isBought: Bool

    init(name: String, store: String = "", note: String = "", isBought: Bool = false) {
        self.name     = name
        self.store    = store
        self.note     = note
        self.isBought = isBought
    }
}
