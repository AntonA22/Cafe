// MARK: - DTO (под твой JSON)

struct CartDTO: Decodable {
    let id: Int
    let userId: Int
    let items: [CartItemDTO]
    let total: Int

    enum CodingKeys: String, CodingKey {
        case id, items, total
        case userId = "user_id"
    }
}

struct CartItemDTO: Decodable {
    let id: Int
    let dessertId: Int
    let qty: Int
    let price: Int
    let sum: Int
    let dessert: CartDessertDTO

    enum CodingKeys: String, CodingKey {
        case id, qty, price, sum, dessert
        case dessertId = "dessert_id"
    }
}

struct CartDessertDTO: Decodable {
    let id: Int
    let name: String
    let description: String
    let photos: [String]?
}

// request bodies
struct CartAddItemDTO: Encodable {
    let dessertId: Int
    let qty: Int
}

struct CartSetQtyDTO: Encodable {
    let qty: Int
}

// ответ на POST/PATCH часто {"success":true,"message":"..."} — ок
struct SuccessDTO: Decodable {
    let success: Bool?
    let message: String?
}

