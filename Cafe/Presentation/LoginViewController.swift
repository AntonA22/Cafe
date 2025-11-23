import UIKit
import Supabase
import Lottie

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
    
    let animationView = LottieAnimationView(name: "LottieLogo1")
   
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
                setupLottieAnimation()
                animationView.play()
                let response = try await supabase.auth.signUp(
                    email: username,
                    password: password
                )
                animationView.stop()
                let user = response.user
                print("Login successful! User ID: \(user.id), Email: \(user.email ?? "no email")")
                
                // Переход на главный экран (Tab Bar Controller)
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    // Получаем Tab Bar Controller по Storyboard ID
                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                        
                        // Выбираем первую вкладку
                        tabBarVC.selectedIndex = 0
                        
                        // Делаем Tab Bar Controller корневым
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                           let window = sceneDelegate.window {
                            
                            window.rootViewController = tabBarVC
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
    
    private func setupLottieAnimation() {
           // Create the title label
           /*let titleLabel = UILabel()
           titleLabel.text = ""
           titleLabel.textAlignment = .center
           titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           */
           // Create the Lottie animation view
        print("trying to set lottie");
          // let animationView = LottieAnimationView(name: "LottieLogo1")
           animationView.contentMode = .scaleAspectFit
           animationView.loopMode = .loop
           animationView.translatesAutoresizingMaskIntoConstraints = false
           
           // Add subviews
           //view.addSubview(titleLabel)
           view.addSubview(animationView)
           
           // Setup constraints
           NSLayoutConstraint.activate([
               // Title label constraints
            
              /* titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
               titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
              */
               // Animation view constraints
              // animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
               animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor)
           ])
           
           // Play the animation
          
       }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
