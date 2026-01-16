import Foundation

enum SyncAPIError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int)
    case decodingFailed
    case encodingFailed
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "同步網址錯誤"
        case .badStatus(let code): return "伺服器回應錯誤：HTTP \(code)"
        case .decodingFailed: return "資料解析失敗"
        case .encodingFailed: return "資料編碼失敗"
        case .network(let e): return "網路錯誤：\(e.localizedDescription)"
        }
    }
}

final class SyncAPI {
    let baseURL: String // e.g. "http://192.168.0.10:8080"

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func uploadOrders(_ reqBody: SyncUploadRequest) async throws -> SyncUploadResponse {
        guard let url = URL(string: "\(baseURL)/api/sync/upload") else {
            throw SyncAPIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = makeEncoder()
            req.httpBody = try encoder.encode(reqBody)
        } catch {
            throw SyncAPIError.encodingFailed
        }

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw SyncAPIError.badStatus(-1) }
            guard (200...299).contains(http.statusCode) else { throw SyncAPIError.badStatus(http.statusCode) }

            do {
                let decoder = makeDecoder()
                return try decoder.decode(SyncUploadResponse.self, from: data)
            } catch {
                throw SyncAPIError.decodingFailed
            }

        } catch {
            throw SyncAPIError.network(error)
        }
    }

    func downloadMasterData(sinceISO8601: String?) async throws -> SyncDownloadResponse {
        var urlString = "\(baseURL)/api/sync/download"
        if let since = sinceISO8601, !since.isEmpty {
            urlString += "?since=\(since.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? since)"
        }

        guard let url = URL(string: urlString) else { throw SyncAPIError.invalidURL }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard let http = resp as? HTTPURLResponse else { throw SyncAPIError.badStatus(-1) }
            guard (200...299).contains(http.statusCode) else { throw SyncAPIError.badStatus(http.statusCode) }

            do {
                let decoder = makeDecoder()
                return try decoder.decode(SyncDownloadResponse.self, from: data)
            } catch {
                throw SyncAPIError.decodingFailed
            }

        } catch {
            throw SyncAPIError.network(error)
        }
    }
}
