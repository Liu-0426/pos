import SwiftUI

struct CustomerPickerSheet: View {
    @EnvironmentObject var vm: POSViewModel
    @Binding var isPresented: Bool
    @State private var keyword: String = ""

    var filtered: [Customer] {
        let k = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if k.isEmpty { return vm.customers }
        return vm.customers.filter { $0.name.localizedCaseInsensitiveContains(k) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("搜尋客戶名稱", text: $keyword)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                List(filtered) { c in
                    Button {
                        vm.selectedCustomer = c
                        vm.refreshPrices()    // ✅ 重新套用客戶特價
                        isPresented = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(c.name).font(.headline)
                                if let phone = c.phone {
                                    Text(phone).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text("欠款 \(ReceiptFormatter.money(c.debt))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("選擇客戶")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") { isPresented = false }
                }
            }
        }
    }
}
