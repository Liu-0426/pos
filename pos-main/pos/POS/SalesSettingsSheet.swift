import SwiftUI

struct SalesSettingsSheet: View {
    @EnvironmentObject var vm: POSViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("業務") {
                    TextField("業務姓名", text: $vm.salesName)
                    TextField("服務電話", text: $vm.servicePhone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("業務設定")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { isPresented = false }
                }
            }
        }
    }
}

