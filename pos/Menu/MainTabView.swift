import SwiftUI

struct MainTabView: View {
    @StateObject private var vm = POSViewModel()

    var body: some View {
        TabView {

            NavigationStack {
                POSView()
            }
            .tabItem { Label("POS", systemImage: "cart") }

            NavigationStack {
                OrdersListView()
            }
            .tabItem { Label("訂單", systemImage: "doc.text") }

            NavigationStack {
                CustomersListView()
            }
            .tabItem { Label("客戶", systemImage: "person.2") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("設定", systemImage: "gearshape") }
        }
        .environmentObject(vm)
    }
}
