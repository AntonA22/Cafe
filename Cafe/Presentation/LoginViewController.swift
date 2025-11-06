import UIKit
import Supabase

struct LoginRequest: Codable {
    let id: Int
    let username: String
    let password: String
}

struct User: Decodable {
    let id: Int
    let username: String
    let password: String
}

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://ahasxpolxjysjrcvulgw.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoYXN4cG9seGp5c2pyY3Z1bGd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTMzMjUsImV4cCI6MjA3NzkyOTMyNX0.hGakP8HMHj3BgfS-lpM0kz1xZ8QV26tD4KjWSYo4gfI"
        )
    }
}

final class LoginViewController: UIViewController {
    

    // MARK: - IBOutlet
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passInput: UITextField!
    
    // MARK: - IBAction
    @IBAction func loginClick(_ sender: Any) {
        guard let username = loginInput.text, !username.isEmpty,
              let password = passInput.text, !password.isEmpty else {
                print("Поля пустые")
                return
        }
            
        let supabase = SupabaseService.shared.client
            
        Task {
            do {
                let supabase = SupabaseService.shared.client
                
                let response = try await supabase
                    .from("users_swift")
                    .select()
                    .eq("username", value: username)
                    .execute()
                
                let users = try JSONDecoder().decode([User].self, from: response.data)

                guard let user = users.first else {
                    print("Пользователь не найден")
                    return
                }

                if user.password == password {
                    print("Успешный вход!")
                } else {
                    print("Неверный пароль")
                }
                
            } catch {
                print("Ошибка supabase:", error)
            }
        }
        
        
//            guard let email = loginInput.text, !email.isEmpty,
//                  let password = passInput.text, !password.isEmpty else {
//                print("Поля пустые")
//                return
//            }
//
//            let url = URL(string: "https://cafe.com/api/login")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let body = LoginRequest(email: email, password: password)
//            request.httpBody = try? JSONEncoder().encode(body)
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//
//                if let error = error {
//                    print("Ошибка сети:", error)
//                    return
//                }
//
//            }.resume()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
