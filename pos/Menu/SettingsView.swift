import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("連線") {
                NavigationLink {
                    PrinterSettingsView()
                } label: {
                    Label("印表機連線設定", systemImage: "printer")
                }
            }

            Section("資料") {
                // 之後可放：匯出 orders.json / 匯入客戶商品 / 同步
                Label("（預留）資料匯出 / 同步", systemImage: "tray.and.arrow.up")
                    .foregroundStyle(.secondary)
            }
            NavigationLink {
                SyncView()
            } label: {
                Label("資料同步", systemImage: "arrow.triangle.2.circlepath")
            }

        }
        .navigationTitle("設定")
    }
}
