import Foundation
import Combine

@MainActor
final class SyncService: ObservableObject {

    enum Phase: Equatable {
        case idle
        case uploading
        case downloading
        case done
        case failed(String)
    }

    @Published var phase: Phase = .idle
    @Published var progressText: String = ""
    @Published var lastSyncText: String = "-"
    @Published var pendingCount: Int = 0

    /// 目前同步用的 server base url
    var baseURL: String {
        LocalStore.getServerBaseURL() ?? "http://192.168.0.10:8080"
    }

    func refreshStatus() {
        pendingCount = LocalStore.countUnsyncedOrders()
        lastSyncText = LocalStore.getLastSyncISO8601() ?? "-"
    }

    func syncNow() async {
        phase = .idle
        progressText = ""

        let api = SyncAPI(baseURL: baseURL)
        let deviceId = LocalStore.deviceId()

        let unsynced = LocalStore.loadUnsyncedOrders()
        pendingCount = unsynced.count

        do {
            // 1) Upload
            if !unsynced.isEmpty {
                phase = .uploading
                progressText = "上傳訂單中（\(unsynced.count) 筆）…"

                let uploadReq = SyncUploadRequest(
                    deviceId: deviceId,
                    appVersion: "1.0.0",
                    orders: unsynced
                )

                let uploadResp = try await api.uploadOrders(uploadReq)

                // ✅ 標記已同步
                LocalStore.markOrdersSynced(orderIds: uploadResp.acceptedOrderIds)

                progressText = "上傳完成，已接收 \(uploadResp.acceptedOrderIds.count) 筆"
            } else {
                progressText = "沒有未同步訂單"
            }

            // 2) Download master data
            phase = .downloading
            progressText = "下載最新客戶/商品資料…"

            let since = LocalStore.getLastSyncISO8601()
            let master = try await api.downloadMasterData(sinceISO8601: since)

            LocalStore.save(master.products, to: LocalStore.productsURL)
            LocalStore.save(master.customers, to: LocalStore.customersURL)
            LocalStore.setLastSyncISO8601(master.serverTimeISO8601)

            phase = .done
            progressText = "同步完成"
            refreshStatus()

        } catch {
            phase = .failed(error.localizedDescription)
            progressText = "同步失敗：\(error.localizedDescription)"
            refreshStatus()
        }
    }
}
