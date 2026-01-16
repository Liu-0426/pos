import SwiftUI

struct RootFlowView: View {
    @StateObject private var vm = POSViewModel()

    var body: some View {
        NavigationStack {
            SalesSelectView()
                .environmentObject(vm)
        }
    }
}
