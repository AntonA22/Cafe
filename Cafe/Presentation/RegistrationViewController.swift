import UIKit



final class RegistrationViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var email_input: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var passInput1: UITextField!
    @IBOutlet weak var passInput2: UITextField!
    
    // MARK: - IBAction
    @IBAction func registrationClick(_ sender: Any) {
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
