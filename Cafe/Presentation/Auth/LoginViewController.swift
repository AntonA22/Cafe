import UIKit
import SnapKit
import Lottie
import Supabase

final class AuthViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI
    private let logoImageView = UIImageView()

    private let loginLabel = UILabel()
    private let loginTF = UITextField()

    private let passwordLabel = UILabel()
    private let passwordTF = UITextField()

    private let errorLabel = UILabel()

    private let forgotPasswordButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)

    private let registrationLabel = UILabel()
    private let registrButton = UIButton(type: .system)

    private let passwordToggleButton = UIButton(type: .custom)

    // Lottie overlay
    private let lottieContainer = UIView()
    private let animationView = LottieAnimationView(name: "LottieLogo1")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupHideKeyboardOnTap()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
            private func setupHideKeyboardOnTap() {
                   let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
                   tapGesture.cancelsTouchesInView = false // важно: позволяет тапать сквозь gesture recognizer
                   view.addGestureRecognizer(tapGesture)
               }
       
    @objc private func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
           print("you tapped somewhere...");
        let location = gesture.location(in: view)
        let tappedView = view.hitTest(location, with: nil)
        let excludedView: UIView = passwordToggleButton
        
        if(    tappedView?.isDescendant(of: excludedView) == true ) {
                   print("Тап по исключенной вьюхе - клавиатура не скрывается")
                   return
               }
           
           view.endEditing(true)
       }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        loginTF.delegate = self
        passwordTF.delegate = self

        // Logo
        logoImageView.image = UIImage(named: "cafe") // <-- поменяй на свой ассет (или Shark.I.logoImage если есть)
        logoImageView.contentMode = .scaleAspectFit

        // Labels
        loginLabel.text = "Логин"
        loginLabel.textColor = UIColor(red: 144/255.0, green: 164/255.0, blue: 174/255.0, alpha: 1.0)
        loginLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        passwordLabel.text = "Пароль"
        passwordLabel.textColor = UIColor(red: 144/255.0, green: 164/255.0, blue: 174/255.0, alpha: 1.0)
        passwordLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        // TextFields
        configureTextField(loginTF, placeholder: "Введите логин", isSecure: false)
        loginTF.returnKeyType = .next
        loginTF.autocapitalizationType = .none
        loginTF.autocorrectionType = .no
        loginTF.keyboardType = .emailAddress
        loginTF.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)

        configurePasswordToggleButton()
        configureTextField(passwordTF, placeholder: "Введите пароль", isSecure: true)
        passwordTF.returnKeyType = .done
        passwordTF.autocapitalizationType = .none
        passwordTF.autocorrectionType = .no
        passwordTF.rightView = passwordToggleButton
        passwordTF.rightViewMode = .always
        passwordTF.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)

        // Error label
        errorLabel.text = "Неверный логин или пароль."
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .red
        errorLabel.isHidden = true

        // Buttons
        forgotPasswordButton.setTitle("Забыли пароль?", for: .normal)
        forgotPasswordButton.contentHorizontalAlignment = .left
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)

        loginButton.setTitle("Войти в систему", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        registrationLabel.text = "Нет аккаунта в системе?"
        registrationLabel.textColor = UIColor(red: 84/255.0, green: 110/255.0, blue: 122/255.0, alpha: 1.0)
        registrationLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        registrButton.setTitle("Регистрация", for: .normal)
        registrButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.15)
        registrButton.setTitleColor(UIColor(red: 0/255, green: 101/255, blue: 255/255, alpha: 1), for: .normal)
        registrButton.layer.cornerRadius = 10
        registrButton.addTarget(self, action: #selector(registrButtonTapped), for: .touchUpInside)

        // Add subviews
        [logoImageView, loginLabel, loginTF, passwordLabel, passwordTF, errorLabel, forgotPasswordButton, loginButton, registrationLabel, registrButton].forEach {
            view.addSubview($0)
        }

        setupConstraints()
        setupLottieOverlay()
    }

    private func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalTo(logoImageView.snp.width)
        }

        loginLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(16)
        }

        loginTF.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(loginTF.snp.bottom).offset(16)
            $0.leading.equalTo(loginLabel)
        }

        passwordTF.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTF.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        forgotPasswordButton.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(22)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(forgotPasswordButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        registrationLabel.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }

        registrButton.snp.makeConstraints {
            $0.top.equalTo(registrationLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    private func configureTextField(_ tf: UITextField, placeholder: String, isSecure: Bool) {
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = .clear
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 207/255.0, green: 216/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        tf.isSecureTextEntry = isSecure

        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        tf.leftView = leftPadding
        tf.leftViewMode = .always
    }

    private func configurePasswordToggleButton() {
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordToggleButton.tintColor = UIColor(red: 144/255.0, green: 164/255.0, blue: 174/255.0, alpha: 1.0)
        passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }

    // MARK: - Lottie
    private func setupLottieOverlay() {
        lottieContainer.isHidden = true
        lottieContainer.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        lottieContainer.layer.cornerRadius = 16
        lottieContainer.clipsToBounds = true

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop

        view.addSubview(lottieContainer)
        lottieContainer.addSubview(animationView)

        lottieContainer.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(160)
        }

        animationView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }

    @MainActor
    private func setLoading(_ isLoading: Bool) {
        lottieContainer.isHidden = !isLoading
        if isLoading {
            animationView.play()
        } else {
            animationView.stop()
        }

        loginButton.isEnabled = !isLoading
        registrButton.isEnabled = !isLoading
        forgotPasswordButton.isEnabled = !isLoading
    }

    // MARK: - Actions
    @objc private func textDidChange(_ sender: UITextField) {
        resetAuthorizationError()
    }

    @objc private func forgotPasswordButtonTapped() {
        let vc = ForgotViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func registrButtonTapped() {
        let vc = RegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        let login = (loginTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !login.isEmpty, !password.isEmpty else {
            showAuthorizationError()
            return
        }

        Task {
            await setLoading(true)
            defer { Task { @MainActor in await self.setLoading(false) } }

            do {
                print("LOGIN TAP: start")

                try await AuthService.shared.login(login: login, password: password)
                print("LOGIN: success, token =", AuthService.shared.currentToken() ?? "nil")

                let user = try await AuthService.shared.fetchMe()
                print("FETCH ME: success, user id =", user.id)

                await MainActor.run {
                    self.openMainTabBar(user: user)
                }

            } catch {
                print("LOGIN ERROR:", error)
                await MainActor.run {
                    self.showAuthorizationError()
                }
            }
        }
    }

    private func openMainTabBar(user: UserDTO) {
        let tabBarVC = MainTabBarController(user: user)

        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
        else { return }

        UIView.transition(with: window,
                          duration: 0.3,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          animations: {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        })
    }

    // MARK: - Error UI
    private func resetAuthorizationError() {
        loginTF.layer.borderColor = UIColor(red: 207/255.0, green: 216/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        passwordTF.layer.borderColor = UIColor(red: 207/255.0, green: 216/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        errorLabel.isHidden = true
    }

    private func showAuthorizationError() {
        loginTF.layer.borderColor = UIColor.red.cgColor
        passwordTF.layer.borderColor = UIColor.red.cgColor
        errorLabel.isHidden = false
    }

    // MARK: - Password toggle
    @objc private func togglePasswordVisibility() {
        passwordTF.isSecureTextEntry.toggle()
        let imageName = passwordTF.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Keyboard
    //дает возможность что-то изменить при появлении/скрытии клавиатуры
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let bottomInset = keyboardSize.height

        let buttonMaxY = loginButton.frame.origin.y + loginButton.frame.height
        let distanceToKeyboard = view.frame.height - bottomInset - buttonMaxY

        if distanceToKeyboard < 10 {
            view.frame.origin.y = -(10 - distanceToKeyboard)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTF {
            passwordTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
