import SwiftUI

struct CustomerSelectView: View {
    @EnvironmentObject var vm: POSViewModel
    @State private var keyword: String = ""

    var filtered: [Customer] {
        if keyword.trimmingCharacters(in: .whitespaces).isEmpty { return vm.customers }
        return vm.customers.filter { $0.name.localizedCaseInsensitiveContains(keyword) }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("搜尋客戶名稱", text: $keyword)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()

            List(filtered) { c in
                Button {
                    vm.selectedCustomer = c
                    vm.refreshPrices()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(c.name).font(.headline)
                            if let phone = c.phone { Text(phone).font(.subheadline).foregroundStyle(.secondary) }
                        }
                        Spacer()
                        Text("欠款 \(ReceiptFormatter.money(c.debt))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            NavigationLink("進入 POS") {
                POSView()
                    .environmentObject(vm)
            }
            .padding()
            .disabled(vm.selectedCustomer == nil)
        }
        .navigationTitle("選擇客戶")
    }
}
