//
//  CartAddItemDTO.swift
//  Cafe
//
//  Created by Антон Абалуев on 24.01.2026.
//


import Foundation

struct CartAddItemDTO: Encodable { let dessert_id: Int; let qty: Int }
struct CartSetQtyDTO: Encodable { let qty: Int }
struct SuccessDTO: Decodable { let success: Bool? }

final class CartService {
    static let shared = CartService()
    private init() {}

    private let api = APIClient.shared

    func getCart() async throws -> CartResponseDTO {
        // если {"data": {...}}
        let wrapped: DataWrapper<CartResponseDTO> = try await api.request("/cart", method: "GET", authorized: true)
        return wrapped.data
    }

    func addItem(dessertId: Int, qty: Int = 1) async throws -> CartResponseDTO {
        let _: SuccessDTO = try await api.request(
            "/cart/items",
            method: "POST",
            body: CartAddItemDTO(dessert_id: dessertId, qty: qty),
            authorized: true
        )
        return try await getCart()
    }

    func setQty(dessertId: Int, qty: Int) async throws -> CartResponseDTO {
        let _: SuccessDTO = try await api.request(
            "/cart/items/\(dessertId)",
            method: "PATCH",
            body: CartSetQtyDTO(qty: qty),
            authorized: true
        )
        return try await getCart()
    }

    func removeItem(dessertId: Int) async throws -> CartResponseDTO {
        let wrapped: DataWrapper<CartResponseDTO> = try await api.request(
            "/cart/items/\(dessertId)",
            method: "DELETE",
            authorized: true
        )
        return wrapped.data
    }

    func clearCart() async throws -> CartResponseDTO {
        let wrapped: DataWrapper<CartResponseDTO> = try await api.request(
            "/cart",
            method: "DELETE",
            authorized: true
        )
        return wrapped.data
    }
}