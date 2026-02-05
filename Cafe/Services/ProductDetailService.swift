//
//  ProductDetailService.swift
//  Cafe
//
//  Created by Антон Абалуев on 03.01.2026.
//

import Foundation

struct ProductDetailResponse: Codable {
    let success: Bool
    let data: Product?
    let error: String?
}

enum ProductDetailError: LocalizedError {
    case invalidURL
    case badStatus(Int, String?)
    case apiError(String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .badStatus(let code, let body):
            return body ?? "Ошибка сервера (\(code))"
        case .apiError(let msg):
            return msg
        case .decoding:
            return "Ошибка обработки данных"
        }
    }
}

import Foundation

final class ProductDetailService {
    static let shared = ProductDetailService()
    private init() {}

    private let api = APIClient.shared

    func fetchProduct(id: Int) async throws -> Product {
        // APIClient.decodeSuccess умеет:
        // 1) {"data": T}
        // 2) {"success":true,"data":T,"error":...}
        // 3) direct T
        try await api.request("/product/\(id)", method: "GET")
    }
}
