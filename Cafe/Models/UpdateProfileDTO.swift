//
//  UpdateProfileDTO.swift
//  Cafe
//
//  Created by Антон Абалуев on 05.01.2026.
//

import Foundation

struct UpdateProfileDTO: Encodable {
    let username: String?
    let email: String?
    let phone: String?
    let first_name: String?
    let last_name: String?
}
