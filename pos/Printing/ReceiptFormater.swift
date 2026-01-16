import Foundation

enum ReceiptFormatter {
    static func format(order: Order) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let lines: [String] = [
            order.companyTitle,
            "",
            "單號：\(order.orderNo)",
            "服務電話：\(order.servicePhone)",
            "業務名：\(order.salesName)",
            "客戶名：\(order.customerName)",
            "",
            "商品明細",
            "--------------------------------",
        ]
        var body = lines

        for item in order.items {
            body.append("\(item.name)")
            body.append("  單價 \(money(item.unitPrice))  x\(item.qty)  小計 \(money(item.subtotal))")
        }

        body.append("--------------------------------")
        body.append("總金額：\(money(order.total))")
        body.append("本次收款：\(money(order.paidAmount))")
        body.append("欠款：\(money(order.newDebt))")
        body.append("")
        body.append("銷售日期：\(df.string(from: order.createdAt))")

        return body.joined(separator: "\n")
    }

    static func money(_ value: Decimal) -> String {
        let ns = value as NSDecimalNumber
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        return f.string(from: ns) ?? "\(ns)"
    }
}
