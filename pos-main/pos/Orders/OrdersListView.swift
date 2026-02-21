import SwiftUI

struct OrdersListView: View {
    @EnvironmentObject var vm: POSViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Text("總訂單數")
                    Spacer()
                    Text("\(vm.orders.count)")
                }
            }

            Section("訂單列表") {
                ForEach(vm.orders.reversed()) { order in
                    NavigationLink {
                        OrderDetailView(order: order)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(order.orderNo)
                                .font(.headline)
                            Text("\(order.customerName)｜\(ReceiptFormatter.money(order.total))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("訂單")
    }
}
