import Foundation

// 上傳：訂單批次
struct SyncUploadRequest: Codable {
    let deviceId: String
    let appVersion: String
    let orders: [Order]
}

struct SyncUploadResponse: Codable {
    let acceptedOrderIds: [UUID]
    let serverTimeISO8601: String
}

// 下載：主資料批次
struct SyncDownloadResponse: Codable {
    let serverTimeISO8601: String
    let products: [Product]
    let customers: [Customer]
}
