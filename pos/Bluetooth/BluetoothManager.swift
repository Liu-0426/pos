import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BluetoothManager: NSObject, ObservableObject {

    // MARK: - Singleton（⭐ 關鍵）
    static let shared = BluetoothManager()

    // MARK: - Published State
    @Published var isBluetoothOn = false
    @Published var isScanning = false
    @Published var peripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isConnected: Bool = false
    @Published var connectedDeviceName: String?

    // MARK: - Bluetooth Core
    private var central: CBCentralManager!
    var writeCharacteristic: CBCharacteristic?

    // MARK: - Init（私有，避免被 View new）
    private override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Scan
    func startScan() {
        guard isBluetoothOn else { return }
        peripherals.removeAll()
        isScanning = true
        central.scanForPeripherals(withServices: nil)
    }

    func stopScan() {
        isScanning = false
        central.stopScan()
    }

    // MARK: - Connect / Disconnect
    func connect(_ peripheral: CBPeripheral) {
        stopScan()
        central.connect(peripheral)
    }

    /// ⚠️ 只有使用者「明確選擇斷線」才會呼叫
    func disconnect() {
        guard let p = connectedPeripheral else { return }
        central.cancelPeripheralConnection(p)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = (central.state == .poweredOn)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            peripherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedDeviceName = peripheral.name
        isConnected = true

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if connectedPeripheral?.identifier == peripheral.identifier {
            connectedPeripheral = nil
            connectedDeviceName = nil
            isConnected = false
            writeCharacteristic = nil
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        service.characteristics?.forEach { c in
            if c.properties.contains(.write) ||
               c.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = c
            }
        }
    }
}

// MARK: - Printing
extension BluetoothManager {

    func printText(_ text: String) {
        guard let peripheral = connectedPeripheral,
              let char = writeCharacteristic else {
            print("❌ 尚未連線印表機")
            return
        }

        guard let data = text.data(using: .utf8) else {
            print("❌ 轉成 Data 失敗")
            return
        }

        // 分段送出（避免 MTU 問題）
        let mtu = 100
        var offset = 0

        while offset < data.count {
            let chunkSize = min(mtu, data.count - offset)
            let chunk = data.subdata(in: offset..<offset + chunkSize)

            peripheral.writeValue(
                chunk,
                for: char,
                type: .withResponse
            )

            offset += chunkSize
        }

        print("✅ 列印資料已送出")
    }
}
