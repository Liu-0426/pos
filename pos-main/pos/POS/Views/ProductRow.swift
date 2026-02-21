import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var vm: POSViewModel
    let product: Product

    var body: some View {
        let price: Decimal = {
            guard let customer = vm.selectedCustomer else {
                return product.basePrice
            }
            return vm.unitPrice(for: product, customer: customer)
        }()

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("[\(product.sku)] \(product.name)")
                    .font(.headline)

                Text("庫存：\(product.stock)｜單價：\(ReceiptFormatter.money(price))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Stepper(
                value: Binding(
                    get: { vm.qty(for: product) },
                    set: { vm.setQty(for: product, qty: $0) }
                ),
                in: 0...max(0, product.stock)
            ) {
                Text("\(vm.qty(for: product))")
                    .monospacedDigit()
            }
            .frame(width: 130)
        }
        .padding(.vertical, 4)
    }
}
