import Foundation

struct Product: Identifiable, Hashable, Codable {
    let id: UUID
    var sku: String
    var name: String
    var stock: Int
    var basePrice: Decimal
    var cost: Decimal?

    init(id: UUID = UUID(), sku: String, name: String, stock: Int, basePrice: Decimal, cost: Decimal? = nil) {
        self.id = id
        self.sku = sku
        self.name = name
        self.stock = stock
        self.basePrice = basePrice
        self.cost = cost
    }
}
