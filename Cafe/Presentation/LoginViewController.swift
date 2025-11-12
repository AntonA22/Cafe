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
                    let response = try await supabase.auth.signUp(
                        email: username,
                        password: password
                    )
                    
                    let user = response.user
                    print("Login successful! User ID: \(user.id), Email: \(user.email ?? "no email")")
                    
                    // Здесь можно перейти на следующий экран
                    // Переход на главный экран
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainWindowViewController") as? MainWindowViewController {
                            
                            // Делаем главный экран корневым
                            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                               let window = sceneDelegate.window {
                                
                                window.rootViewController = mainVC
                                UIView.transition(with: window,
                                                  duration: 0.3,
                                                  options: .transitionFlipFromRight,
                                                  animations: nil)
                            }
                        }
                    }
                } catch {
                    // Ошибка Supabase (неверный пароль, нет подключения и т.д.)
                    print("Ошибка при логине:", error.localizedDescription)
                }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
