import Foundation

struct Order: Identifiable, Hashable, Codable {
    let id: UUID
    var orderNo: String
    var companyTitle: String

    var salesName: String
    var servicePhone: String

    var customerId: UUID
    var customerName: String
    var previousDebt: Decimal

    var items: [CartItem]
    var total: Decimal

    // ✅ 新增：本次收款
    var paidAmount: Decimal

    // ✅ 新欠款（= previousDebt + total - paidAmount）
    var newDebt: Decimal

    var createdAt: Date
    var isSynced: Bool = false

    init(id: UUID = UUID(),
         orderNo: String,
         companyTitle: String = "永昕弘有限公司",
         salesName: String,
         servicePhone: String,
         customerId: UUID,
         customerName: String,
         previousDebt: Decimal,
         items: [CartItem],
         total: Decimal,
         paidAmount: Decimal,
         newDebt: Decimal,
         createdAt: Date = Date()) {
        self.id = id
        self.orderNo = orderNo
        self.companyTitle = companyTitle
        self.salesName = salesName
        self.servicePhone = servicePhone
        self.customerId = customerId
        self.customerName = customerName
        self.previousDebt = previousDebt
        self.items = items
        self.total = total
        self.paidAmount = paidAmount
        self.newDebt = newDebt
        self.createdAt = createdAt
    }
}
