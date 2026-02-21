//
//  posApp.swift
//  pos
//
//  Created by 紫寧 on 2026/1/5.
//

import SwiftUI

@main
struct posApp: App {
    @StateObject private var bluetooth = BluetoothManager.shared
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(bluetooth) 
        }
    }
}
