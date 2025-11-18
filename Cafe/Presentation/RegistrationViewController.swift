import UIKit



struct RegistrationRequest: Codable {
    let login: String
    let email: String
    let name: String
    let password1: String
    let password2: String
}

struct UserInsert: Codable {
    let username: String
    let email: String
    let name: String
    let password: String
}

struct ProfileInsert: Codable {
    let email: String
    let name: String
    let password: String
}

final class RegistrationViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var email_input: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var passInput1: UITextField!
    @IBOutlet weak var passInput2: UITextField!
    
    // MARK: - IBAction
    @IBAction func registrationClick(_ sender: Any) {
        guard let login = loginInput.text, !login.isEmpty,
                  let email = email_input.text, !email.isEmpty,
                  let name = nameInput.text, !name.isEmpty,
                  let p1 = passInput1.text, !p1.isEmpty,
                  let p2 = passInput2.text, !p2.isEmpty else {
                print("Поля пустые")
                return
            }

        if p1 != p2 {
            print("Пароли не совпадают")
            return
        }

        let supabase = SupabaseService.shared.client
        
        Task {
            do {
                let response = try await supabase.auth.signUp(
                    email: email,
                    password: p1,
                    data: [
                        "name": .string(name),
                      ]
                )
                
                let user = response.user
                print("Registration successful! User ID: \(user.id), Email: \(user.email ?? "no email"), Name: \(user.userMetadata["name"]?.stringValue ?? "no name")")
                
                let profile = ProfileInsert(
                    email: email,
                    name: name,
                    password: p1
                )

                try await supabase
                       .from("users_swift")
                       .insert(profile)       // Передаём Encodable объект
                       .execute()

            } catch {
                print("Ошибка при создании:", error)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
