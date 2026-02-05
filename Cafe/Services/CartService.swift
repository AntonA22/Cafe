import Foundation

// MARK: - Service

extension Notification.Name {
    static let cartDidChange = Notification.Name("cartDidChange")
}


final class CartService {
    static let shared = CartService()
    private init() {}

    private let api = APIClient.shared
    
    private func notifyCartChanged(_ cart: CartDTO) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cartDidChange, object: cart)
        }
    }

    // GET /cart  -> {"data": {...}}
    func getCart() async throws -> CartDTO {
        try await api.request("/cart", method: "GET", authorized: true)
    }

    // POST /cart/items
    func addItem(dessertId: Int, qty: Int = 1) async throws -> CartDTO {
        let _: SuccessDTO = try await api.request(
            "/cart/items",
            method: "POST",
            body: CartAddItemDTO(dessertId: dessertId, qty: qty),
            authorized: true
        )
        let cart = try await getCart()
        notifyCartChanged(cart)
        return cart
    }

    // PATCH /cart/items/{dessertId}
    func setQty(dessertId: Int, qty: Int) async throws -> CartDTO {
        let _: SuccessDTO = try await api.request(
            "/cart/items/\(dessertId)",
            method: "PATCH",
            body: CartSetQtyDTO(qty: qty),
            authorized: true
        )
        let cart = try await getCart()
        notifyCartChanged(cart)
        return cart
    }

    // DELETE /cart/items/{dessertId} -> {"data": {...}}
    func removeItem(dessertId: Int) async throws -> CartDTO {
        let cart: CartDTO = try await api.request(
            "/cart/items/\(dessertId)",
            method: "DELETE",
            authorized: true
        )
        notifyCartChanged(cart)
        return cart
    }


    // DELETE /cart -> {"data": {...}}
    func clearCart() async throws -> CartDTO {
        let cart: CartDTO = try await api.request(
            "/cart",
            method: "DELETE",
            authorized: true
        )
        notifyCartChanged(cart)
        return cart
    }
}

