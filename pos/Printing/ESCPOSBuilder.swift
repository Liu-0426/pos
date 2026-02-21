import Foundation

enum ESCPOSBuilder {

    static func receipt(from text: String) -> Data {
        var data = Data()

        // 初始化
        data.append(contentsOf: [0x1B, 0x40]) // ESC @

        // 文字（UTF-8）
        if let body = text.data(using: .utf8) {
            data.append(body)
        }

        // 換行
        data.append(0x0A)
        data.append(0x0A)

        // 切紙（有些機器不支援，但加了沒壞處）
        data.append(contentsOf: [0x1D, 0x56, 0x00])

        return data
    }
}
