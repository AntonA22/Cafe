//
//  AddressService.swift
//  Cafe
//
//  Created by Антон Абалуев on 04.02.2026.
//

import Foundation

struct AddressDTO: Codable {
    let id: String
    let title: String
    let baseAddress: String
    let entrance: String?
    let intercom: String?
    let floor: String?
    let flat: String?
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case id, title, entrance, intercom, floor, flat, latitude, longitude
        case baseAddress = "base_address"
    }
}

struct EmptyResponse: Decodable {}

struct AddressUpsertDTO: Codable {
    let title: String
    let baseAddress: String
    let entrance: String?
    let intercom: String?
    let floor: String?
    let flat: String?
    let latitude: Double
    let longitude: Double
}

final class AddressService {
    static let shared = AddressService()
    private init() {}

    private let api = APIClient.shared

    // GET /addresses
    func getAddresses() async throws -> [AddressDTO] {
        try await api.request("/addresses", method: "GET", authorized: true)
    }

    // POST /addresses
    func createAddress(_ dto: AddressUpsertDTO) async throws -> AddressDTO {
        try await api.request(
            "/addresses",
            method: "POST",
            body: dto,
            authorized: true
        )
    }

    // PATCH /addresses/{id}
    func updateAddress(id: String, dto: AddressUpsertDTO) async throws -> AddressDTO {
        try await api.request(
            "/addresses/\(id)",
            method: "PUT",
            body: dto,
            authorized: true
        )
    }

    // DELETE /addresses/{id}
    func deleteAddress(id: String) async throws {
        _ = try await api.request(
            "/addresses/\(id)",
            method: "DELETE",
            authorized: true
        ) as EmptyResponse
    }
}
