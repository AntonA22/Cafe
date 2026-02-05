import Foundation

struct LoginDTO: Encodable { let login: String; let password: String }


struct RegisterDTO: Encodable {
    let username: String
    let email: String
    let phone: String?
    let first_name: String?
    let last_name: String?
    let password: String
}
struct AuthResponseDTO: Decodable {
    let token: String
    let user: UserDTO
}

final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let api = APIClient.shared
    private var tokenStorage: TokenStorageProtocol = KeychainTokenStorage.shared

    func login(login: String, password: String) async throws {
        let resp: AuthResponseDTO = try await api.request(
            "/auth/login",
            method: "POST",
            body: LoginDTO(login: login, password: password),
            authorized: false
        )
        tokenStorage.token = resp.token
    }

    func register(
        username: String,
        email: String,
        phone: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        password: String
    ) async throws {

        let resp: AuthResponseDTO = try await api.request(
            "/auth/register",
            method: "POST",
            body: RegisterDTO(
                username: username,
                email: email,
                phone: phone,
                first_name: firstName,
                last_name: lastName,
                password: password
            ),
            authorized: false
        )

        tokenStorage.token = resp.token
    }

    func logout() { tokenStorage.clear() }

    func fetchMe() async throws -> UserDTO {
        //что если ничего не возвращается?????
        try await APIClient.shared.request("/me", method: "GET", authorized: true)
    }
    
    func updateMe(_ dto: UpdateProfileDTO) async throws -> UserDTO {
        let wrapped: DataWrapper<UserDTO> = try await api.request(
            "/me/update",
            method: "PUT",
            body: dto,
            authorized: true
        )
        return wrapped.data
    }
    
    func currentToken() -> String? {
        tokenStorage.token
    }
}
