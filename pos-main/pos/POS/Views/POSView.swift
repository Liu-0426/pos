import SwiftUI

struct POSView: View {
    @EnvironmentObject var vm: POSViewModel
    @FocusState private var isPaidFocused: Bool

    @State private var showCustomerPicker = false
    @State private var showSalesSettings = false

    var body: some View {
        VStack(spacing: 0) {

            header

            List {
                Section("商品") {
                    ForEach(vm.products) { p in
                        ProductRow(product: p)
                    }
                }

                Section("購物車") {
                    if vm.cart.isEmpty {
                        Text("尚未選擇商品")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.cart) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text("x\(item.qty)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(ReceiptFormatter.money(item.subtotal))
                            }
                        }
                    }
                }
            }

            Divider()

            checkoutPanel
        }
        .navigationTitle("POS")
        .navigationBarTitleDisplayMode(.inline)

        // ✅ 客戶選擇 Sheet
        .sheet(isPresented: $showCustomerPicker) {
            CustomerPickerSheet(isPresented: $showCustomerPicker)
                .environmentObject(vm)
        }

        // ✅ 業務設定 Sheet
        .sheet(isPresented: $showSalesSettings) {
            SalesSettingsSheet(isPresented: $showSalesSettings)
                .environmentObject(vm)
        }

        // 鍵盤完成鍵
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { isPaidFocused = false }
            }
        }
    }

    // MARK: - Header（可點擊切換客戶/業務）
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Button {
                    showCustomerPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle")
                        Text(vm.selectedCustomer?.name ?? "請選擇客戶")
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    showSalesSettings = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.key")
                        Text(vm.salesName.isEmpty ? "設定業務" : vm.salesName)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text("欠款：\(ReceiptFormatter.money(vm.previousDebt))")
                Spacer()
                Text("服務電話：\(vm.servicePhone)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
    }

    // MARK: - Checkout Panel（收款＋結帳）
    private var checkoutPanel: some View {
        VStack(spacing: 10) {

            HStack {
                Text("本次總額")
                Spacer()
                Text(ReceiptFormatter.money(vm.subtotal))
            }

            HStack {
                Text("收款金額")
                TextField("0", text: $vm.paidInput)
                    .keyboardType(.numberPad)
                    .focused($isPaidFocused)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)

                Spacer()

                Button("1000") { vm.paidInput = "1000" }
                Button("5000") { vm.paidInput = "5000" }
            }

            HStack {
                Text("結帳後欠款")
                Spacer()
                Text(ReceiptFormatter.money(vm.newDebt))
                    .foregroundStyle(.secondary)
            }

            Button {
                isPaidFocused = false
                vm.checkout()
            } label: {
                Text("確認結帳 / 列印")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.cart.isEmpty || vm.selectedCustomer == nil || vm.salesName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
