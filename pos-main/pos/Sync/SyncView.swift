import SwiftUI

struct SyncView: View {
    @StateObject private var sync = SyncService()

    var body: some View {
        List {
            Section("狀態") {
                HStack {
                    Text("未同步訂單")
                    Spacer()
                    Text("\(sync.pendingCount) 筆")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("最後同步")
                    Spacer()
                    Text(sync.lastSyncText)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack {
                    Text("伺服器")
                    Spacer()
                    Text(sync.baseURL)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Section("操作") {
                Button {
                    Task { await sync.syncNow() }
                } label: {
                    Label(buttonTitle(sync.phase), systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isBusy(sync.phase))

                if isBusy(sync.phase) {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text(sync.progressText)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(sync.progressText.isEmpty ? "回公司連上 Wi-Fi 後按同步" : sync.progressText)
                        .foregroundStyle(.secondary)
                }

                if case .failed(let msg) = sync.phase {
                    Text(msg).foregroundStyle(.red)
                }
            }

            Section("提示") {
                Text("請確保手機與公司筆電在同一個 Wi-Fi；公司筆電建議用 DHCP reservation 綁定固定 IP。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("資料同步")
        .onAppear { sync.refreshStatus() }
    }

    private func isBusy(_ p: SyncService.Phase) -> Bool {
        p == .uploading || p == .downloading
    }

    private func buttonTitle(_ p: SyncService.Phase) -> String {
        switch p {
        case .uploading: return "上傳中…"
        case .downloading: return "下載中…"
        default: return "立即同步"
        }
    }
}
