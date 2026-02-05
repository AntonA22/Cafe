//
//  ProfileViewController.swift
//  Cafe
//
//  Created by Антон Абалуев on 05.01.2026.
//


import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Data

    private var user: UserDTO?
    private var edited: EditableProfile?
    private var notificationsEnabled: Bool = true

    // чтобы понимать, есть ли изменения
    private var hasChanges: Bool {
        edited?.username != user?.username ||
        edited?.email != user?.email ||
        edited?.phone != user?.phone ||
        edited?.firstName != user?.firstName ||
        edited?.lastName != user?.lastName
    }

    // MARK: - Init

    init() {
        //self.user = user
        //self.edited = EditableProfile(from: user)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground
        setupTable()
        setupKeyboardDismiss()

        fetchProfile()
    }

    private func fetchProfile() {
        Task {
            do {
                let me = try await AuthService.shared.fetchMe()
                await MainActor.run {
                    self.user = me
                    self.edited = EditableProfile(from: me)
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Ошибка", message: (error as? LocalizedError)?.errorDescription ?? "\(error)")
                }
            }
        }
    }

    // MARK: - Setup

    private func setupTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseId)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.keyboardDismissMode = .interactive
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    // MARK: - Actions

    private func saveChangesTapped() {
        guard hasChanges else {
            showAlert(title: "Нет изменений", message: "Вы не изменили данные.")
            return
        }

        Task {
            do {
                // можно показать лоадер (по желанию)
                let dto = UpdateProfileDTO(
                    username: edited?.username.nilIfEmpty,
                    email: edited?.email.nilIfEmpty,
                    phone: edited?.phone.nilIfEmpty,
                    first_name: edited?.firstName.nilIfEmpty,
                    last_name: edited?.lastName.nilIfEmpty
                )

                let updatedUser = try await AuthService.shared.updateMe(dto)

                await MainActor.run {
                    self.user = updatedUser
                    self.edited = EditableProfile(from: updatedUser)
                    self.tableView.reloadData()
                    self.showAlert(title: "Готово", message: "Данные профиля обновлены.")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Ошибка", message: (error as? LocalizedError)?.errorDescription ?? "\(error)")
                }
            }
        }
    }

    private func logoutTapped() {
        AuthService.shared.logout()
        openAuthScreen()
    }

    private func openAddresses() {
        //showAlert(title: "Адреса", message: "Здесь будет экран адресов.")
        let vc = AddressesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openOrders() {
        showAlert(title: "История заказов", message: "Здесь будет история заказов.")
    }

    private func openAuthScreen() {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
        else { return }

        let authVC = AuthViewController()
        let nav = UINavigationController(rootViewController: authVC)

        UIView.transition(with: window,
                          duration: 0.3,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews],
                          animations: {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        })
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - Table

private enum ProfileSection: Int, CaseIterable {
    case personal
    case actions
    case addresses
    case orders
    case notifications
    case logout

    var title: String? {
        switch self {
        case .personal: return "Личные данные"
        case .actions: return nil
        case .addresses: return "Адреса"
        case .orders: return "История заказов"
        case .notifications: return "Настройки уведомлений"
        case .logout: return nil
        }
    }
}

private enum PersonalRow: Int, CaseIterable {
    case firstName, lastName, username, email, phone

    var title: String {
        switch self {
        case .firstName: return "Имя"
        case .lastName: return "Фамилия"
        case .username: return "Логин"
        case .email: return "Email"
        case .phone: return "Телефон"
        }
    }

    var keyboard: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .phone: return .phonePad
        default: return .default
        }
    }

    var autocap: UITextAutocapitalizationType {
        switch self {
        case .email, .username: return .none
        default: return .words
        }
    }
}

// MARK: - Editable state

private struct EditableProfile {
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var phone: String

    init(from user: UserDTO) {
        self.firstName = user.firstName ?? ""
        self.lastName = user.lastName ?? ""
        self.username = user.username ?? ""
        self.email = user.email ?? ""
        self.phone = user.phone ?? ""
    }
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}

// MARK: - DataSource / Delegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        ProfileSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileSection(rawValue: section)! {
        case .personal: return PersonalRow.allCases.count
        case .actions: return 1
        case .addresses: return 1
        case .orders: return 1
        case .notifications: return 1
        case .logout: return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ProfileSection(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = ProfileSection(rawValue: indexPath.section)!

        switch section {

        case .personal:
            let row = PersonalRow(rawValue: indexPath.row)!
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseId, for: indexPath) as! TextFieldCell

            cell.configure(
                title: row.title,
                value: valueForPersonalRow(row),
                keyboard: row.keyboard,
                autocap: row.autocap
            ) { [weak self] text in
                self?.setValueForPersonalRow(row, text: text)
            }

            return cell

        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.accessoryType = .none   // ✅ убрать стрелку

            var cfg = cell.defaultContentConfiguration()
            cfg.text = "Сохранить изменения"
            cfg.textProperties.alignment = .center
            cfg.textProperties.color = hasChanges ? .systemBlue : .systemGray
            cell.contentConfiguration = cfg

            return cell

        case .addresses:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            var cfg = cell.defaultContentConfiguration()
            cfg.text = "Адреса"
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = cfg
            return cell

        case .orders:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            var cfg = cell.defaultContentConfiguration()
            cfg.text = "История заказов"
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = cfg
            return cell

        case .notifications:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseId, for: indexPath) as! SwitchCell
            cell.configure(
                title: "Уведомления",
                isOn: notificationsEnabled
            ) { [weak self] isOn in
                self?.notificationsEnabled = isOn
                // здесь позже можно сохранить в UserDefaults или отправить на API
            }
            return cell

        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.accessoryType = .none   // ✅ убрать стрелку

            var cfg = cell.defaultContentConfiguration()
            cfg.text = "Выйти"
            cfg.textProperties.alignment = .center
            cfg.textProperties.color = .systemRed
            cell.contentConfiguration = cfg

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch ProfileSection(rawValue: indexPath.section)! {
        case .actions:
            saveChangesTapped()
        case .addresses:
            openAddresses()
        case .orders:
            openOrders()
        case .logout:
            logoutTapped()
        default:
            break
        }
    }

    private func valueForPersonalRow(_ row: PersonalRow) -> String {
        switch row {
        case .firstName: return edited?.firstName ?? ""
        case .lastName: return edited?.lastName ?? ""
        case .username: return edited?.username ?? ""
        case .email: return edited?.email ?? ""
        case .phone: return edited?.phone ?? ""
        }
    }

    private func setValueForPersonalRow(_ row: PersonalRow, text: String) {
        switch row {
        case .firstName: edited?.firstName = text
        case .lastName: edited?.lastName = text
        case .username: edited?.username = text
        case .email: edited?.email = text
        case .phone: edited?.phone = text
        }

        // обновим вид кнопки "Сохранить изменения"
        if let idx = ProfileSection.allCases.firstIndex(of: .actions) {
            tableView.reloadSections(IndexSet(integer: idx), with: .none)
        }
    }
}
