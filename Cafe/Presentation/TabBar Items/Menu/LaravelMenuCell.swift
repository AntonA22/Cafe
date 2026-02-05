//
//  LaravelMenuCell.swift
//  Cafe
//
//  Created by Антон Абалуев on 30.01.2026.
//
import UIKit
import Foundation

class LaravelMenuCell: UICollectionViewCell {

    private var productId: Int?
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    private let cartImageView = UIImageView()
    
    weak var parentViewController: UIViewController?

    
    private var quantity: Int = 0 {
        didSet { updateCartUI() }
    }
    private let qtyContainer = UIStackView()
    private let qtyBackgroundView = UIView()
    private let minusButton = UIButton(type: .system)
    private let qtyLabel = UILabel()
    private let plusButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let imageTag = tappedImageView.tag
        print("Image tapped \(imageTag)")
        
        let detailVC = ProductDetailViewController()
        detailVC.productId = imageTag
        
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // поддерживаем оба размера
            sheet.selectedDetentIdentifier = .large // сразу открываем на больший размер
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        
        parentViewController?.present(detailVC, animated: true)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true

        // Tap on image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let radius: CGFloat = 12
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = radius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center

        // addToCartButton
        addToCartButton.backgroundColor = .systemBlue
        addToCartButton.tintColor = .white
        addToCartButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        addToCartButton.layer.cornerRadius = 10
        addToCartButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)

        cartImageView.image = UIImage(systemName: "cart.fill")
        cartImageView.tintColor = .white
        cartImageView.contentMode = .scaleAspectFit

        // qtyContainer
        qtyContainer.axis = .horizontal
        qtyContainer.alignment = .center
        qtyContainer.distribution = .equalCentering
        qtyContainer.spacing = 12
//        qtyContainer.isHidden = true

        minusButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        minusButton.tintColor = .systemBlue
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)

        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        
        minusButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        plusButton.contentEdgeInsets  = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        qtyLabel.textColor = .label
        qtyLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        qtyBackgroundView.layer.borderWidth = 1
        qtyBackgroundView.layer.borderColor = UIColor.systemGray4.cgColor

        qtyLabel.font = .systemFont(ofSize: 16, weight: .bold)
        qtyLabel.textAlignment = .center
        qtyLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        qtyBackgroundView.backgroundColor = UIColor.systemGray6
        qtyBackgroundView.layer.cornerRadius = 16
        qtyBackgroundView.clipsToBounds = true
        
        qtyBackgroundView.addSubview(qtyContainer)
        qtyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        qtyContainer.translatesAutoresizingMaskIntoConstraints = false

        qtyBackgroundView.isHidden = true // по умолчанию скрыт

        qtyContainer.addArrangedSubview(minusButton)
        qtyContainer.addArrangedSubview(qtyLabel)
        qtyContainer.addArrangedSubview(plusButton)

        // controlsStack: в нём либо кнопка, либо qty (оба на одном месте)
        let controlsStack = UIView()
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsStack.addSubview(addToCartButton)
        controlsStack.addSubview(qtyBackgroundView)

        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        qtyContainer.translatesAutoresizingMaskIntoConstraints = false

        // image container (без внутренних отступов)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // info stack (с отступами)
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, controlsStack])
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(infoStack)

        // cart icon inside button
        addToCartButton.addSubview(cartImageView)
        cartImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Image flush to card edges
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // высота картинки как доля ширины (можно 0.6–0.75)
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.62),

            // info stack below image with padding
            infoStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            infoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            infoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            // controlsStack height
            controlsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            // button/qty fill controlsStack
            addToCartButton.topAnchor.constraint(equalTo: controlsStack.topAnchor),
            addToCartButton.leadingAnchor.constraint(equalTo: controlsStack.leadingAnchor),
            addToCartButton.trailingAnchor.constraint(equalTo: controlsStack.trailingAnchor),
            addToCartButton.bottomAnchor.constraint(equalTo: controlsStack.bottomAnchor),

            // qtyBackgroundView fills controlsStack
            qtyBackgroundView.topAnchor.constraint(equalTo: controlsStack.topAnchor),
            qtyBackgroundView.leadingAnchor.constraint(equalTo: controlsStack.leadingAnchor),
            qtyBackgroundView.trailingAnchor.constraint(equalTo: controlsStack.trailingAnchor),
            qtyBackgroundView.bottomAnchor.constraint(equalTo: controlsStack.bottomAnchor),

            // qtyContainer inside qtyBackgroundView with padding
            qtyContainer.topAnchor.constraint(equalTo: qtyBackgroundView.topAnchor, constant: 6),
            qtyContainer.leadingAnchor.constraint(equalTo: qtyBackgroundView.leadingAnchor, constant: 12),
            qtyContainer.trailingAnchor.constraint(equalTo: qtyBackgroundView.trailingAnchor, constant: -12),
            qtyContainer.bottomAnchor.constraint(equalTo: qtyBackgroundView.bottomAnchor, constant: -6),
            
            // cart icon
            cartImageView.trailingAnchor.constraint(equalTo: addToCartButton.trailingAnchor, constant: -10),
            cartImageView.centerYAnchor.constraint(equalTo: addToCartButton.centerYAnchor),
            cartImageView.widthAnchor.constraint(equalToConstant: 18),
            cartImageView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productId = nil
        imageView.image = nil
        titleLabel.text = nil
        quantity = 0
    }

    func configure(item: MenuItem) {
        self.productId = item.id
        titleLabel.text = item.name
        addToCartButton.setTitle("\(item.price) ₽", for: .normal)
        print(item.imageName)
        if (item.imageName.starts(with: "http")) {
            if let url = URL(string: item.imageName) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            // self.view.setNeedsLayout()
                            self.imageView.image = UIImage(named: item.imageName)
                        }
                    }
                }.resume()
            }
        }
        else {        imageView.image = UIImage(named: item.imageName) }
        imageView.tag = item.id;
        
        // пока не знаем qty с сервера — ставим 0
        // позже можно прокинуть qty из модели MenuItem
        quantity = item.qty
    }
    
    private func updateCartUI() {
        // quantity == 0 -> показываем кнопку цены
        let inCart = quantity > 0

        addToCartButton.isHidden = inCart
        qtyBackgroundView.isHidden = !inCart

        qtyLabel.text = "\(max(quantity, 1))"
    }
    
    @objc private func addToCartTapped() {
        guard let productId else { return }
        let capturedId = productId

        Task { [weak self] in
            guard let self else { return }

            do {
                await self.setControlsEnabled(false)

                let cart = try await CartService.shared.addItem(dessertId: capturedId, qty: 1)
                let serverQty = cart.items.first(where: { $0.dessertId == capturedId })?.qty ?? 1

                await MainActor.run {
                    guard self.productId == capturedId else { return } // ✅ защита от reuse
                    self.quantity = serverQty
                }
            } catch {
                print("addToCart error:", error.localizedDescription)
            }

            await self.setControlsEnabled(true)
        }
    }

    @objc private func plusTapped() {
        guard let productId else { return }
        let capturedId = productId

        Task { [weak self] in
            guard let self else { return }

            do {
                await self.setControlsEnabled(false)

                let targetQty = self.quantity + 1
                let cart = try await CartService.shared.setQty(dessertId: capturedId, qty: targetQty)
                let serverQty = cart.items.first(where: { $0.dessertId == capturedId })?.qty ?? targetQty

                await MainActor.run {
                    guard self.productId == capturedId else { return } // ✅
                    self.quantity = serverQty
                }
            } catch {
                print("plusTapped error:", error.localizedDescription)
            }

            await self.setControlsEnabled(true)
        }
    }

    @objc private func minusTapped() {
        guard let productId else { return }
        let capturedId = productId

        Task { [weak self] in
            guard let self else { return }

            do {
                await self.setControlsEnabled(false)

                let targetQty = self.quantity - 1

                if targetQty <= 0 {
                    let cart = try await CartService.shared.removeItem(dessertId: capturedId)
                    let serverQty = cart.items.first(where: { $0.dessertId == capturedId })?.qty ?? 0

                    await MainActor.run {
                        guard self.productId == capturedId else { return } // ✅
                        self.quantity = serverQty
                    }
                } else {
                    let cart = try await CartService.shared.setQty(dessertId: capturedId, qty: targetQty)
                    let serverQty = cart.items.first(where: { $0.dessertId == capturedId })?.qty ?? targetQty

                    await MainActor.run {
                        guard self.productId == capturedId else { return } // ✅
                        self.quantity = serverQty
                    }
                }
            } catch {
                print("minusTapped error:", error.localizedDescription)
            }

            await self.setControlsEnabled(true)
        }
    }
    
    private func setControlsEnabled(_ enabled: Bool) async {
        await MainActor.run {
            self.addToCartButton.isEnabled = enabled
            self.plusButton.isEnabled = enabled
            self.minusButton.isEnabled = enabled
        }
    }
}
