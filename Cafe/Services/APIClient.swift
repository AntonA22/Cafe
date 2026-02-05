import Foundation
import Security

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized(String?)
    case validation([String: [String]])
    case badStatus(Int, String?)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный адрес сервера"
        case .unauthorized(let msg): return msg ?? "Требуется авторизация"
        case .validation(let errors):
            let text = errors.values.flatMap { $0 }.joined(separator: "\n")
            return text.isEmpty ? "Проверьте введённые данные" : text
        case .badStatus(let code, let msg):
            return msg ?? "Ошибка сервера (\(code))"
        case .decoding: return "Ошибка обработки данных"
        case .network(let e): return e.localizedDescription
        }
    }
}

struct DataWrapper<T: Decodable>: Decodable {
    let data: T
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: String?
}

// MARK: - Token storage

protocol TokenStorageProtocol {
    var token: String? { get set }
    func clear()
}

// KeychainTokenStorage — без изменений
final class KeychainTokenStorage: TokenStorageProtocol {
    static let shared = KeychainTokenStorage()
    private init() {}

    private let service = Bundle.main.bundleIdentifier ?? "default.service"
    private let account = "auth_token"

    var token: String? {
        get { read(account: account) }
        set {
            if let newValue { save(newValue, account: account) }
            else { delete(account: account) }
        }
    }

    func clear() { delete(account: account) }

    private func save(_ value: String, account: String) {
        let data = Data(value.utf8)
        delete(account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }

        return value
    }

    private func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - AnyEncodable

private struct AnyEncodable: Encodable {
    private let encodeBlock: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self.encodeBlock = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeBlock(encoder) }
}

// MARK: - APIClient

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = "https://anton.panfilius.ru/api"
    //private let baseURL = "http://127.0.0.1:8000/api"
    private let session: URLSession = .shared
    private var tokenStorage: TokenStorageProtocol = KeychainTokenStorage.shared

    // ✅ УБРАЛИ convertFromSnakeCase — декодим ровно по CodingKeys в DTO
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func request<T: Decodable>(
        _ path: String,
        method: String,
        body: Encodable? = nil,
        authorized: Bool = false
    ) async throws -> T {

        guard let url = URL(string: baseURL + path) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if authorized, let token = tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase   // ✅ ВАЖНО
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        do {
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1

            if (200...299).contains(status) {

                // ✅ если нет тела — просто возвращаем пустой объект
                if data.isEmpty {
                    // создаём "пустышку" нужного типа
                    return try JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!)
                }

                return try decodeSuccess(T.self, from: data)
            }

            if status == 401 {
                let msg = parseLaravelMessage(from: data) ?? String(data: data, encoding: .utf8)
                throw APIError.unauthorized(msg)
            }

            if status == 422, let errors = parseLaravelErrors(from: data) {
                throw APIError.validation(errors)
            }

            let msg = parseLaravelMessage(from: data) ?? String(data: data, encoding: .utf8)
            throw APIError.badStatus(status, msg)

        } catch let e as APIError {
            throw e
        } catch {
            throw APIError.network(error)
        }
    }

    private func decodeSuccess<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {

        // 1) {"data": T}
        if let wrapped = try? decoder.decode(DataWrapper<T>.self, from: data) {
            return wrapped.data
        }

        // 2) {"success":true,"data":T,"error":...}
        if let apiResp = try? decoder.decode(APIResponse<T>.self, from: data) {
            if apiResp.success, let val = apiResp.data { return val }
            throw APIError.badStatus(200, apiResp.error ?? "Unknown API error")
        }

        // 3) Direct (T or [T])
        if let direct = try? decoder.decode(T.self, from: data) {
            return direct
        }

        let body = String(data: data, encoding: .utf8)
        print("🧾 DECODE FAIL BODY:", body ?? "nil")

        throw APIError.decoding(DecodingError.dataCorrupted(.init(
            codingPath: [],
            debugDescription: "Unknown response format",
            underlyingError: nil
        )))
    }
}

// MARK: - Laravel helpers

private func parseLaravelMessage(from data: Data) -> String? {
    guard
        let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let msg = obj["message"] as? String
    else { return nil }
    return msg
}

private func parseLaravelErrors(from data: Data) -> [String: [String]]? {
    guard
        let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let errors = obj["errors"] as? [String: [String]]
    else { return nil }
    return errors
}
