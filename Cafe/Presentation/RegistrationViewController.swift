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
        let body = UserInsert(
            username: login,
            email: email,
            name: name,
            password: p1
        )
        Task {
            do {
                let response = try await supabase
                    .from("users_swift")
                    .insert(body)
                    .execute()

                print("Пользователь создан", response)

            } catch {
                print("Ошибка при создании:", error)
            }
        }
//            guard let login = loginInput.text, !login.isEmpty,
//                  let email = email_input.text, !email.isEmpty,
//                  let name = nameInput.text, !name.isEmpty,
//                  let p1 = passInput1.text, !p1.isEmpty,
//                  let p2 = passInput2.text, !p2.isEmpty else {
//                print("Поля пустые")
//                return
//            }
//            
//            let body = RegistrationRequest(login: login, email: email, name: name, password1: p1, password2: p2)
//            
//            let url = URL(string: "https://cafe.com/api/register")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
