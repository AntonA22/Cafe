import Foundation

struct Product: Codable {
    let id: Int
    let name: String
    let category: String?
    let description: String?
    let price: Double
    let photos: [String]?
    let available: Bool?
    let weight: Double?
    let calories: Int?
    let proteins: Double?
    let fats: Double?
    let carbohydrates: Double?
}

struct SearchDTO: Encodable {
    let query: String
}
  extension SearchDTO {
    func toQueryItems() -> [URLQueryItem] {
        return [URLQueryItem(name: "query", value: self.query)]
    }
}
final class ProductsService {
    static let shared = ProductsService()
    private init() {}

    private let api = APIClient.shared

    func fetchProducts() async throws -> [Product] {
        try await api.request("/products", method: "GET")
    }

    func fetchProduct(id: Int) async throws -> Product {
        let wrapped: DataWrapper<Product> = try await api.request("/product/\(id)", method: "GET")
        return wrapped.data
    }
    
  
    func searchProducts(body: SearchDTO) async throws -> [Product] {
       /* try await api.request(
            "/products/search",
            method: "GET",
            body: body
        )*/
         let urlString = "/products/search"
    var components = URLComponents(string: urlString)!
    components.queryItems = body.toQueryItems()
    
    return try await api.request(
        components.url?.absoluteString ?? "/products/search",
        method: "GET"
    )
    }
}
