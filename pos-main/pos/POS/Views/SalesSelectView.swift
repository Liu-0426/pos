import SwiftUI

struct SalesSelectView: View {
    @EnvironmentObject var vm: POSViewModel

    var body: some View {
        Form {
            Section("業務人員") {
                TextField("業務姓名", text: $vm.salesName)
                TextField("服務電話", text: $vm.servicePhone)
                    .keyboardType(.phonePad)
            }

            Section {
                NavigationLink("下一步：選擇客戶") {
                    CustomerSelectView()
                        .environmentObject(vm)
                }
                .disabled(vm.salesName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("登入/業務選擇")
    }
}
