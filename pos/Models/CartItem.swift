import Foundation

struct CartItem: Identifiable, Hashable, Codable {
    let id: UUID
    let productId: UUID
    var sku: String
    var name: String
    var unitPrice: Decimal
    var qty: Int

    init(id: UUID = UUID(), productId: UUID, sku: String, name: String, unitPrice: Decimal, qty: Int) {
        self.id = id
        self.productId = productId
        self.sku = sku
        self.name = name
        self.unitPrice = unitPrice
        self.qty = qty
    }

    var subtotal: Decimal {
        unitPrice * Decimal(qty)
    }
}
