//
//  AdressesMock.swift
//  Cafe
//
//  Created by Антон Абалуев on 03.02.2026.
//

import Foundation

struct Address: Identifiable {
    let id: String                    // ✅ один id — серверный

    var title: String
    var baseAddress: String

    var entrance: String?
    var intercom: String?
    var floor: String?
    var flat: String?

    var coordinate: Coordinate

    init(
        id: String,
        title: String,
        baseAddress: String,
        entrance: String? = nil,
        intercom: String? = nil,
        floor: String? = nil,
        flat: String? = nil,
        coordinate: Coordinate
    ) {
        self.id = id
        self.title = title
        self.baseAddress = baseAddress
        self.entrance = entrance
        self.intercom = intercom
        self.floor = floor
        self.flat = flat
        self.coordinate = coordinate
    }

    var subtitle: String {
        var parts: [String] = []
        if !baseAddress.isEmpty { parts.append(baseAddress) }

        if let entrance, !entrance.isEmpty { parts.append("подъезд \(entrance)") }
        if let intercom, !intercom.isEmpty { parts.append("домофон \(intercom)") }
        if let floor, !floor.isEmpty { parts.append("этаж \(floor)") }
        if let flat, !flat.isEmpty { parts.append(flat) }

        return parts.joined(separator: ", ")
    }
}

extension Address {
    init(dto: AddressDTO) {
        self.init(
            id: dto.id, // ✅ серверный id 그대로
            title: dto.title,
            baseAddress: dto.baseAddress,
            entrance: dto.entrance,
            intercom: dto.intercom,
            floor: dto.floor,
            flat: dto.flat,
            coordinate: Coordinate(latitude: dto.latitude, longitude: dto.longitude)
        )
    }

    func toUpsertDTO() -> AddressUpsertDTO {
        AddressUpsertDTO(
            title: title,
            baseAddress: baseAddress,
            entrance: entrance,
            intercom: intercom,
            floor: floor,
            flat: flat,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}
