//
//  CartViewController.swift
//  Cafe
//
//  Created by Антон Абалуев on 07.01.2026.
//

import UIKit

final class CartViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var items: [CartItemDTO] = [] {
        didSet { updateUI() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavBar()
        setupTableView()
        setupFooter()
        Task { await loadCart() }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cartDidChange(_:)),
                                               name: .cartDidChange,
                                               object: nil)

    }
    
    @objc private func cartDidChange(_ notification: Notification) {
        guard let cart = notification.object as? CartDTO else { return }
        self.items = cart.items
    }
    
    // MARK: - NavBar

    func setupNavBar() {
        title = "Корзина"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Товаров: 0", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(clearCartTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    func updateNavBar() {
        navigationItem.leftBarButtonItem?.title = "Товаров: \(items.count)"
    }

    // MARK: - TableView

    func setupTableView() {
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Footer

    func setupFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        let totalLabel = UILabel()
        totalLabel.tag = 100
        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Оформить заказ", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(checkout), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [totalLabel, button])
        stack.axis = .vertical
        stack.spacing = 16
        footer.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])

        tableView.tableFooterView = footer
    }

    func updateFooter() {
        let total = items.reduce(0) { $0 + $1.sum }
        let label = tableView.tableFooterView?.viewWithTag(100) as? UILabel
        label?.text = "Итого: \(total) ₽"
    }

    // MARK: - Actions

    @objc func checkout() {
        print("Оформляем заказ 🚀")
    }

    @objc func clearCartTapped() {
        Task {
            do {
                let cart = try await CartService.shared.clearCart()
                self.items = cart.items
            } catch {
                print("Ошибка очистки корзины:", error)
            }
        }
    }

    // MARK: - Load Cart

    private func loadCart() async {
        do {
            let cart = try await CartService.shared.getCart()
            self.items = cart.items
        } catch {
            print("Ошибка загрузки корзины:", error)
        }
    }

    // MARK: - Update Item Quantity

    private func updateItem(_ item: CartItemDTO, delta: Int) {
        Task {
            do {
                let newQty = item.qty + delta
                if newQty <= 0 {
                    try await CartService.shared.removeItem(dessertId: item.dessertId)
                } else {
                    try await CartService.shared.setQty(dessertId: item.dessertId, qty: newQty)
                }
                await loadCart() // обновляем UI
            } catch {
                print("Ошибка обновления позиции:", error)
            }
        }
    }

    private func updateUI() {
        updateNavBar()
        updateFooter()
        tableView.reloadData()

        if items.isEmpty {
            let label = UILabel()
            label.text = "Корзина пуста 🛒"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
}

// MARK: - TableView DataSource & Delegate

extension CartViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseId, for: indexPath) as! CartItemCell
        cell.configure(with: items[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            updateItem(items[indexPath.row], delta: -items[indexPath.row].qty)
        }
    }
}

// MARK: - CartItemCellDelegate

extension CartViewController: CartItemCellDelegate {

    func didTapPlus(on item: CartItemDTO) { updateItem(item, delta: 1) }
    func didTapMinus(on item: CartItemDTO) { updateItem(item, delta: -1) }
}
