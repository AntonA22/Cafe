import UIKit
import SnapKit



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

final class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI

    private let titleLabel = UILabel()

    private let emailLabel = UILabel()
    private let emailTF = UITextField()

    private let loginLabel = UILabel()
    private let loginTF = UITextField()

    private let firstNameLabel = UILabel()
    private let firstNameTF = UITextField()

    private let lastNameLabel = UILabel()
    private let lastNameTF = UITextField()

    private let passwordLabel = UILabel()
    private let passwordTF = UITextField()

    private let errorLabel = UILabel()

    private let registerButton = UIButton(type: .system)
    private let infoLabel = UILabel()
    private let backButton = UIButton(type: .system)

    // MARK: - Services

    private let supabase = SupabaseService.shared.client

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateRegisterButton()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Title
        titleLabel.text = "Регистрация нового\nаккаунта"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 2

        // Labels
        configureLabel(emailLabel, text: "Email")
        configureLabel(loginLabel, text: "Логин")
        configureLabel(firstNameLabel, text: "Имя")
        configureLabel(lastNameLabel, text: "Фамилия")
        configureLabel(passwordLabel, text: "Пароль")

        // TextFields
        configureTextField(emailTF, placeholder: "Введите почту", keyboard: .emailAddress)
        configureTextField(loginTF, placeholder: "Введите логин")
        configureTextField(firstNameTF, placeholder: "Введите имя")
        configureTextField(lastNameTF, placeholder: "Введите фамилию")
        configureTextField(passwordTF, placeholder: "Введите пароль", secure: true)

        // Error
        errorLabel.text = "Ошибка регистрации"
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true

        // Register button
        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        registerButton.isEnabled = false

        // Info
        infoLabel.text = "Уже есть аккаунт в системе?"
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = UIColor(hex: "#546E7A")
        infoLabel.textAlignment = .center

        // Back
        backButton.setTitle("Вернуться к авторизации", for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        backButton.setTitleColor(.systemBlue, for: .normal)

        // Add
        [
            titleLabel,
            emailLabel, emailTF,
            errorLabel,
            loginLabel, loginTF,
            firstNameLabel, firstNameTF,
            lastNameLabel, lastNameTF,
            passwordLabel, passwordTF,
            registerButton,
            infoLabel,
            backButton
        ].forEach { view.addSubview($0) }

        // Layout
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        layoutField(emailLabel, emailTF, top: titleLabel.snp.bottom, offset: 24)
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTF.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        layoutField(loginLabel, loginTF, top: errorLabel.snp.bottom, offset: 16)
        layoutField(firstNameLabel, firstNameTF, top: loginTF.snp.bottom, offset: 16)
        layoutField(lastNameLabel, lastNameTF, top: firstNameTF.snp.bottom, offset: 16)
        layoutField(passwordLabel, passwordTF, top: lastNameTF.snp.bottom, offset: 16)

        registerButton.snp.makeConstraints {
            $0.top.equalTo(passwordTF.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        infoLabel.snp.makeConstraints {
            $0.top.equalTo(registerButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    // MARK: - Actions

    private func setupActions() {
        [emailTF, loginTF, firstNameTF, lastNameTF, passwordTF].forEach {
            $0.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        }
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    @objc private func textChanged() {
        resetError()
        updateRegisterButton()
    }

    @objc private func registerTapped() {
        guard
            let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
            let login = loginTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !login.isEmpty,
            let firstName = firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !firstName.isEmpty,
            let lastName = lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lastName.isEmpty,
            let password = passwordTF.text, !password.isEmpty
        else {
            showError("Заполните все поля")
            return
        }

        Task {
            do {
                try await AuthService.shared.register(
                    username: login,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    password: password
                )

                await MainActor.run {
                    navigationController?.popViewController(animated: true)
                }

            } catch {
                await MainActor.run {
                    // если у тебя APIError: LocalizedError (как я делал) — покажет текст с сервера/422
                    showError(error.localizedDescription.isEmpty ? "Ошибка регистрации" : error.localizedDescription)
                }
                print("Register error:", error)
            }
        }
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Helpers

    private func updateRegisterButton() {
        let filled = !(emailTF.text?.isEmpty ?? true)
            && !(loginTF.text?.isEmpty ?? true)
            && !(firstNameTF.text?.isEmpty ?? true)
            && !(lastNameTF.text?.isEmpty ?? true)
            && !(passwordTF.text?.isEmpty ?? true)

        registerButton.isEnabled = filled
        registerButton.backgroundColor = filled ? .systemBlue : .systemBlue.withAlphaComponent(0.5)
    }

    private func showError(_ text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }

    private func resetError() {
        errorLabel.isHidden = true
    }

    private func configureLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor(red: 144/255, green: 164/255, blue: 174/255, alpha: 1)
    }

    private func configureTextField(
        _ tf: UITextField,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        secure: Bool = false
    ) {
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 15)
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 1).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        tf.keyboardType = keyboard
        tf.isSecureTextEntry = secure
        tf.delegate = self
    }

    private func layoutField(
        _ label: UILabel,
        _ field: UITextField,
        top: ConstraintItem,
        offset: CGFloat
    ) {
        label.snp.makeConstraints {
            $0.top.equalTo(top).offset(offset)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        field.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
}

// MARK: - UIColor HEX

private extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex.removeFirst()
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xff) / 255,
            green: CGFloat((rgb >> 8) & 0xff) / 255,
            blue: CGFloat(rgb & 0xff) / 255,
            alpha: 1
        )
    }
}
