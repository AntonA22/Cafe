//
//  ForgotViewController.swift
//  Cafe-iOS-Anton
//
//  Created by Антон Абалуев on 06.12.2025.
//

import UIKit
import SnapKit

// MARK: - Protocols


final class ForgotViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI

    private let logoImageView = UIImageView()
    private let passwordRecoveryLabel = UILabel()

    private let loginLabel = UILabel()
    private let loginTF = UITextField()

    private let errorLabel = UILabel()
    private let passwordRecoveryButton = UIButton(type: .system)

    private let attentionMessageLabel2 = UILabel()
    private let attentionMessageLabel = UILabel()

    private let backButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePasswordRecoveryButtonState()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Logo
        view.addSubview(logoImageView)
        logoImageView.image = UIImage(named: "cafe") // <- положи лого в Assets и назови "AppLogo"
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalTo(logoImageView.snp.width)
        }

        // Title
        view.addSubview(passwordRecoveryLabel)
        passwordRecoveryLabel.text = "Восстановление\nпароля"
        passwordRecoveryLabel.font = .boldSystemFont(ofSize: 28)
        passwordRecoveryLabel.numberOfLines = 2
        passwordRecoveryLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        // Login label
        view.addSubview(loginLabel)
        loginLabel.text = "Логин"
        loginLabel.textColor = UIColor(red: 144/255.0, green: 164/255.0, blue: 174/255.0, alpha: 1.0)
        loginLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        loginLabel.snp.makeConstraints {
            $0.top.equalTo(passwordRecoveryLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }

        // TextField
        view.addSubview(loginTF)
        loginTF.placeholder = "Введите почту (email)"
        loginTF.font = UIFont.systemFont(ofSize: 15)
        loginTF.backgroundColor = .clear
        loginTF.layer.cornerRadius = 10
        loginTF.layer.borderWidth = 1
        loginTF.layer.borderColor = UIColor(red: 207/255.0, green: 216/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        loginTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        loginTF.leftViewMode = .always
        loginTF.keyboardType = .emailAddress
        loginTF.autocapitalizationType = .none
        loginTF.autocorrectionType = .no
        loginTF.returnKeyType = .done
        loginTF.delegate = self
        loginTF.addTarget(self, action: #selector(loginTextFiledDidTapped(_:)), for: .editingChanged)
        loginTF.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(loginLabel.snp.bottom).offset(4)
            $0.height.equalTo(50)
        }

        // Error
        view.addSubview(errorLabel)
        errorLabel.text = "Пользователь не найден"
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(18)
            $0.top.equalTo(loginTF.snp.bottom).offset(6)
        }

        // Button
        view.addSubview(passwordRecoveryButton)
        passwordRecoveryButton.setTitle("Восстановить пароль", for: .normal)
        passwordRecoveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        passwordRecoveryButton.layer.cornerRadius = 10
        passwordRecoveryButton.setTitleColor(.white, for: .normal)
        passwordRecoveryButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.5)
        passwordRecoveryButton.isEnabled = false
        passwordRecoveryButton.addTarget(self, action: #selector(passwordRecoveryButtonTapped), for: .touchUpInside)
        passwordRecoveryButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(errorLabel.snp.bottom).offset(16)
            $0.height.equalTo(50)
        }

        // Success label (hidden by default)
        view.addSubview(attentionMessageLabel2)
        attentionMessageLabel2.text = "Ссылка для сброса пароля\nотправлена на указанную почту"
        attentionMessageLabel2.textColor = .black
        attentionMessageLabel2.numberOfLines = 2
        attentionMessageLabel2.font = .boldSystemFont(ofSize: 19)
        attentionMessageLabel2.isHidden = true
        attentionMessageLabel2.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        // Info label
        view.addSubview(attentionMessageLabel)
        attentionMessageLabel.text = "Мы пришлем ссылку на сброс пароля на вашу почту.\nПосле сброса вы сможете задать новый пароль и войти."
        attentionMessageLabel.textColor = UIColor(named: "#546E7A")
        attentionMessageLabel.numberOfLines = 0
        attentionMessageLabel.font = UIFont.systemFont(ofSize: 13)
        attentionMessageLabel.snp.makeConstraints {
            $0.top.equalTo(passwordRecoveryButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        // Back
        view.addSubview(backButton)
        backButton.setTitle("Вернуться к авторизации", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.15)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(attentionMessageLabel.snp.bottom).offset(20)
            $0.height.equalTo(50)
        }
    }

    // MARK: - Actions

    @objc private func loginTextFiledDidTapped(_ textField: UITextField) {
        resetAuthorizationError()
        updatePasswordRecoveryButtonState()
    }

    @objc private func passwordRecoveryButtonTapped() {
        guard let email = loginTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAuthorizationError()
            return
        }

        resetAuthorizationError()

        // ✅ РОУТИНГА ТУТ НЕТ — тут бизнес-логика через presenter
    }

    @objc private func backButtonTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - UI State

    private func updatePasswordRecoveryButtonState() {
        let isEmpty = loginTF.text?.isEmpty ?? true
        passwordRecoveryButton.isEnabled = !isEmpty
        passwordRecoveryButton.backgroundColor = isEmpty
            ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.5)
            : UIColor.systemBlue
    }

    private func resetAuthorizationError() {
        loginTF.layer.borderColor = UIColor(red: 207/255.0, green: 216/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        errorLabel.isHidden = true
    }

    func showAuthorizationError() {
        loginTF.layer.borderColor = UIColor.red.cgColor
        errorLabel.isHidden = false
    }

    /// Вызывай это из presenter после успешной отправки письма
    func showSuccess() {
        attentionMessageLabel2.isHidden = false
        loginTF.isHidden = true
        loginLabel.isHidden = true
        passwordRecoveryButton.isHidden = true
        errorLabel.isHidden = true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
