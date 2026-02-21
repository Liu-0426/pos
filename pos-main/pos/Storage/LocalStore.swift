import Foundation

enum LocalStore {

    // MARK: - Paths

    private static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private static func fileURL(_ name: String) -> URL {
        documentsURL().appendingPathComponent(name)
    }

    static let customersURL = fileURL("customers.json")
    static let productsURL  = fileURL("products.json")
    static let ordersURL    = fileURL("orders.json")

    // MARK: - Generic Load / Save

    static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    static func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("LocalStore save error:", error)
        }
    }

    // MARK: - Device ID（每台手機唯一）

    static func deviceId() -> String {
        let key = "device_id"

        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    // MARK: - Server URL（公司電腦內網）

    static func getServerBaseURL() -> String? {
        UserDefaults.standard.string(forKey: "server_base_url")
    }

    static func setServerBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "server_base_url")
    }

    // MARK: - Last Sync Time

    static func getLastSyncISO8601() -> String? {
        UserDefaults.standard.string(forKey: "last_sync_iso8601")
    }

    static func setLastSyncISO8601(_ iso: String) {
        UserDefaults.standard.set(iso, forKey: "last_sync_iso8601")
    }

    // MARK: - Append Single Order（給同步用）

    static func appendOrder(_ order: Order) {
        var items = load([Order].self, from: ordersURL) ?? []
        items.append(order)
        save(items, to: ordersURL)
    }

    // MARK: - Unsynced Orders

    static func loadUnsyncedOrders() -> [Order] {
        let items = load([Order].self, from: ordersURL) ?? []
        return items.filter { $0.isSynced == false }
    }

    static func countUnsyncedOrders() -> Int {
        loadUnsyncedOrders().count
    }

    static func markOrdersSynced(orderIds: [UUID]) {
        var items = load([Order].self, from: ordersURL) ?? []
        let idSet = Set(orderIds)

        for i in items.indices {
            if idSet.contains(items[i].id) {
                items[i].isSynced = true
            }
        }

        save(items, to: ordersURL)
    }
}
