import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        List {
            Section("基本資訊") {
                row("單號", order.orderNo)
                row("業務", order.salesName)
                row("客戶", order.customerName)
                row("日期", order.createdAt.formatted())
            }

            Section("金額") {
                row("總金額", ReceiptFormatter.money(order.total))
                row("本次收款", ReceiptFormatter.money(order.paidAmount))
                row("結帳後欠款", ReceiptFormatter.money(order.newDebt))
            }

            Section("商品明細") {
                ForEach(order.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("x\(item.qty)  單價 \(ReceiptFormatter.money(item.unitPrice))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("訂單明細")
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}
