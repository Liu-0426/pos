import SwiftUI

struct CustomersListView: View {
    @EnvironmentObject var vm: POSViewModel
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(vm.customers) { customer in
                NavigationLink {
                    CustomerEditView(customer: customer)
                } label: {
                    VStack(alignment: .leading) {
                        Text(customer.name)
                        Text("欠款 \(ReceiptFormatter.money(customer.debt))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("客戶")
        .toolbar {
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAdd) {
            CustomerEditView(customer: nil)
        }
    }
}
