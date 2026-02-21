import Foundation

struct Customer: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var phone: String?
    var address: String?
    var debt: Decimal

    /// 客戶特價：productId -> price
    var priceOverrides: [UUID: Decimal]

    init(id: UUID = UUID(),
         name: String,
         phone: String? = nil,
         address: String? = nil,
         debt: Decimal,
         priceOverrides: [UUID: Decimal] = [:]) {
        self.id = id
        self.name = name
        self.phone = phone
        self.address = address
        self.debt = debt
        self.priceOverrides = priceOverrides
    }
}
