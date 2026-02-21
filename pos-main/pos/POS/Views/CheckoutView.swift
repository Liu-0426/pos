import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var vm: POSViewModel
    @FocusState private var isPaidFieldFocused: Bool

    var body: some View {
        VStack(spacing: 12) {

            // ✅ 收款輸入區
            VStack(alignment: .leading, spacing: 8) {
                Text("本次收款金額")
                    .font(.headline)

                TextField("輸入收款金額（例如 1000）", text: $vm.paidInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($isPaidFieldFocused)

                HStack {
                    Text("本次總金額")
                    Spacer()
                    Text(ReceiptFormatter.money(vm.subtotal))
                }

                HStack {
                    Text("原欠款")
                    Spacer()
                    Text(ReceiptFormatter.money(vm.previousDebt))
                }

                HStack {
                    Text("結帳後欠款")
                    Spacer()
                    Text(ReceiptFormatter.money(vm.newDebt))
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Button {
                // 收起鍵盤再結帳（體驗更好）
                isPaidFieldFocused = false
                vm.checkout()
            } label: {
                Text("確認結帳（產生收據）")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.cart.isEmpty ||
                      vm.selectedCustomer == nil ||
                      vm.salesName.trimmingCharacters(in: .whitespaces).isEmpty)

            if vm.lastReceiptText.isEmpty {
                Text("尚未產生收據")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    Text(vm.lastReceiptText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }

                Button("列印（目前：模擬）") {
                    // 之後接 BluetoothPrinterService.print(text:)
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("結帳 / 收據")

        // ✅ 鍵盤上方工具列：完成
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    isPaidFieldFocused = false
                }
            }
        }
    }
}
