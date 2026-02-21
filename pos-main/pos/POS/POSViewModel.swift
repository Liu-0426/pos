import Foundation
import SwiftUI
import Combine

@MainActor
final class POSViewModel: ObservableObject {

    // MARK: - 業務 / 設定

    @Published var salesName: String = ""
    @Published var servicePhone: String = "04-0000-0000"

    // ✅ 新增：本次收款輸入（字串，方便 TextField 綁定）
    @Published var paidInput: String = ""

    // MARK: - 資料來源（本機）

    @Published var customers: [Customer] = []
    @Published var products: [Product] = []
    @Published var orders: [Order] = []

    // MARK: - POS 狀態

    @Published var selectedCustomer: Customer? = nil
    @Published var cart: [CartItem] = []

    // MARK: - 結帳 / 收據

    @Published var lastOrder: Order? = nil
    @Published var lastReceiptText: String = ""

    // MARK: - 內部狀態

    private var dailyCounter: Int = 0

    // MARK: - Init

    init() {
        loadLocalData()
    }

    // MARK: - Local Data Load / Save

    func loadLocalData() {
        if let savedCustomers = LocalStore.load([Customer].self, from: LocalStore.customersURL),
           let savedProducts  = LocalStore.load([Product].self, from: LocalStore.productsURL) {

            customers = savedCustomers
            products = savedProducts

        } else {
            seedDemoData()
            saveAll()
        }

        if let savedOrders = LocalStore.load([Order].self, from: LocalStore.ordersURL) {
            orders = savedOrders
        } else {
            orders = []
        }

        rebuildDailyCounter()
    }

    func saveAll() {
        LocalStore.save(customers, to: LocalStore.customersURL)
        LocalStore.save(products,  to: LocalStore.productsURL)
        LocalStore.save(orders,    to: LocalStore.ordersURL)
    }

    // MARK: - Demo Seed（第一次啟動）

    func seedDemoData() {
        let p1 = Product(sku: "A001", name: "威士忌 700ml", stock: 20, basePrice: 1200)
        let p2 = Product(sku: "B002", name: "紅酒 750ml", stock: 35, basePrice: 850)
        let p3 = Product(sku: "C003", name: "啤酒 330ml", stock: 200, basePrice: 45)

        products = [p1, p2, p3]

        var c1 = Customer(
            name: "瑞琦菸酒（A店）",
            phone: "0912-000-000",
            address: "台中市 X 路",
            debt: 5000
        )
        c1.priceOverrides[p1.id] = 1100

        let c2 = Customer(
            name: "瑞琦菸酒（B店）",
            phone: "0922-000-000",
            address: "台中市 Y 路",
            debt: 0
        )

        customers = [c1, c2]
    }

    // MARK: - 收款解析

    /// 將 paidInput 轉成 Decimal（空字串 = 0）
    var paidAmount: Decimal {
        let trimmed = paidInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return 0 }
        return Decimal(string: trimmed) ?? 0
    }

    // MARK: - 商品價格 / 購物車

    func unitPrice(for product: Product, customer: Customer) -> Decimal {
        customer.priceOverrides[product.id] ?? product.basePrice
    }

    func qty(for product: Product) -> Int {
        cart.first(where: { $0.productId == product.id })?.qty ?? 0
    }

    func setQty(for product: Product, qty: Int) {
        guard let customer = selectedCustomer else { return }

        let qty = max(0, qty)

        if let idx = cart.firstIndex(where: { $0.productId == product.id }) {
            if qty == 0 {
                cart.remove(at: idx)
            } else {
                cart[idx].qty = qty
            }
        } else {
            if qty == 0 { return }
            let price = unitPrice(for: product, customer: customer)
            let item = CartItem(
                productId: product.id,
                sku: product.sku,
                name: product.name,
                unitPrice: price,
                qty: qty
            )
            cart.append(item)
        }

        refreshPrices()
    }

    func refreshPrices() {
        guard let customer = selectedCustomer else { return }

        for idx in cart.indices {
            if let product = products.first(where: { $0.id == cart[idx].productId }) {
                cart[idx].unitPrice = unitPrice(for: product, customer: customer)
            }
        }
    }

    // MARK: - 金額計算

    var subtotal: Decimal {
        cart.reduce(0) { $0 + $1.subtotal }
    }

    var previousDebt: Decimal {
        selectedCustomer?.debt ?? 0
    }

    /// ✅ 新欠款 = 原欠款 + 本次總額 - 本次收款（最小 0）
    var newDebt: Decimal {
        let debt = previousDebt + subtotal - paidAmount
        return max(0, debt)
    }

    // MARK: - Checkout

    func checkout() {
        guard let customer = selectedCustomer else { return }
        guard !salesName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard !cart.isEmpty else { return }

        let paid = paidAmount
        let computedNewDebt = max(0, customer.debt + subtotal - paid)

        let order = Order(
            orderNo: generateOrderNo(),
            salesName: salesName,
            servicePhone: servicePhone,
            customerId: customer.id,
            customerName: customer.name,
            previousDebt: customer.debt,
            items: cart,
            total: subtotal,
            paidAmount: paid,
            newDebt: computedNewDebt
        )

        lastOrder = order
        lastReceiptText = ReceiptFormatter.format(order: order)

        // 更新欠款
        if let idx = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[idx].debt = order.newDebt
            selectedCustomer = customers[idx]
        }

        // 儲存訂單（ViewModel 狀態）
        orders.append(order)

        // ✅ 新增：寫入本機 orders.json（給同步用）
        // 你目前 LocalStore 是工具類，所以用 LocalStore.appendOrder(order)
        LocalStore.appendOrder(order)

        // 原本存檔（customers/products/orders）
        saveAll()

        // 清空購物車 + 清空收款輸入
        cart = []
        paidInput = ""
    }

    // MARK: - 單號產生

    func generateOrderNo() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        dailyCounter += 1
        return "RQL-\(df.string(from: Date()))-\(String(format: "%04d", dailyCounter))"
    }

    private func rebuildDailyCounter() {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let today = df.string(from: Date())

        let todayOrders = orders.filter {
            $0.orderNo.contains(today)
        }

        dailyCounter = todayOrders.count
    }

    // MARK: - Reset / Debug（開發用）

    func resetAllData() {
        customers = []
        products = []
        orders = []
        cart = []
        selectedCustomer = nil
        lastOrder = nil
        lastReceiptText = ""
        paidInput = ""

        LocalStore.save(customers, to: LocalStore.customersURL)
        LocalStore.save(products, to: LocalStore.productsURL)
        LocalStore.save(orders, to: LocalStore.ordersURL)
    }
}
