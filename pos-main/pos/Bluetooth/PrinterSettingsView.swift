import SwiftUI
import CoreBluetooth

struct PrinterSettingsView: View {
    @StateObject private var bt = BluetoothManager()

    var body: some View {
        List {

            Section("狀態") {
                HStack {
                    Text("藍牙")
                    Spacer()
                    Text(bt.isBluetoothOn ? "開啟" : "關閉")
                        .foregroundStyle(bt.isBluetoothOn ? .green : .red)
                }

                HStack {
                    Text("目前連線")
                    Spacer()
                    Text(bt.connectedPeripheral?.name ?? "未連線")
                        .foregroundStyle(.secondary)
                }
            }

            Section("裝置") {
                Button {
                    bt.isScanning ? bt.stopScan() : bt.startScan()
                } label: {
                    Label(
                        bt.isScanning ? "停止掃描" : "掃描藍牙裝置",
                        systemImage: "magnifyingglass"
                    )
                }

                ForEach(bt.peripherals, id: \.identifier) { p in
                    Button {
                        bt.connect(p)
                    } label: {
                        HStack {
                            Text(p.name ?? "未知裝置")
                            Spacer()
                            if bt.connectedPeripheral?.identifier == p.identifier {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }

                if bt.connectedPeripheral != nil {
                    Button(role: .destructive) {
                        bt.disconnect()
                    } label: {
                        Text("中斷連線")
                    }
                }
            }
        }
        .navigationTitle("印表機設定")
    }
}
