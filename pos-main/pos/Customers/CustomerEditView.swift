import SwiftUI

struct CustomerEditView: View {
    @EnvironmentObject var vm: POSViewModel
    @Environment(\.dismiss) private var dismiss

    var customer: Customer?

    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var debt = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("客戶名稱", text: $name)
                TextField("電話", text: $phone)
                TextField("地址", text: $address)
                TextField("欠款", text: $debt)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(customer == nil ? "新增客戶" : "編輯客戶")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let c = customer {
                    name = c.name
                    phone = c.phone ?? ""
                    address = c.address ?? ""
                    debt = "\(c.debt)"
                }
            }
        }
    }

    private func save() {
        let debtValue = Decimal(string: debt) ?? 0

        if let c = customer,
           let idx = vm.customers.firstIndex(where: { $0.id == c.id }) {

            vm.customers[idx].name = name
            vm.customers[idx].phone = phone.isEmpty ? nil : phone
            vm.customers[idx].address = address.isEmpty ? nil : address
            vm.customers[idx].debt = debtValue

        } else {
            let new = Customer(
                name: name,
                phone: phone.isEmpty ? nil : phone,
                address: address.isEmpty ? nil : address,
                debt: debtValue
            )
            vm.customers.append(new)
        }

        vm.saveAll()
    }
}
