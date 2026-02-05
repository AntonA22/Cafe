//
//  ProductDetailViewController.swift
//  Cafe
//
//  Created by Антон Абалуев on 27.11.2025.
//

import UIKit

class ProductDetailViewController: UIViewController, UIScrollViewDelegate {

    var productId: Int?
    
    private var isImagesBuilt = false

    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageScrollView = UIScrollView()
    private let pageControl = UIPageControl()

    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let nutritionStack = UIStackView()

    private var images: [UIImage] = []
    private var currentIndex: Int = 0
    
    private let bottomBar = UIView()
    private let priceBottomLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        setupUI()
        
        // точки должны листать картинки!
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)

        loadProduct()
    }

    // MARK: UI SETUP
    private func setupUI() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // ------------------------
        // Карусель фото
        // ------------------------
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.isPagingEnabled = true
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.delegate = self
        contentView.addSubview(imageScrollView)

        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageScrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageScrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageScrollView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
        
        /// точки для картинок
        pageControl.hidesForSinglePage = false
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        // ------------------------
        // Название
        // ------------------------
        nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 16),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])

        // ------------------------
        // Цена
        // ------------------------
        priceLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        priceLabel.textColor = .systemGreen
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor)
        ])

        // ------------------------
        // Описание
        // ------------------------
        descriptionLabel.font = .systemFont(ofSize: 17)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            descriptionLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor)
        ])

        // ------------------------
        // Таблица нутриентов
        // ------------------------
        nutritionStack.axis = .horizontal
        nutritionStack.distribution = .fillEqually
        nutritionStack.spacing = 10
        nutritionStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nutritionStack)
        NSLayoutConstraint.activate([
            nutritionStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            nutritionStack.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            nutritionStack.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            nutritionStack.heightAnchor.constraint(equalToConstant: 70),
            nutritionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        // ------------------------
        // Нижняя панель покупки
        // ------------------------
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .systemBackground
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.1
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomBar.layer.shadowRadius = 6

        view.addSubview(bottomBar)

        NSLayoutConstraint.activate([
            bottomBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor), // до самого низа
            bottomBar.heightAnchor.constraint(equalToConstant: 100)
        ])

        // PRICE LABEL
        priceBottomLabel.font = .systemFont(ofSize: 22, weight: .bold)
        priceBottomLabel.textColor = .label
        priceBottomLabel.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.addSubview(priceBottomLabel)

        // ADD TO CART BUTTON
        addToCartButton.setTitle("В корзину", for: .normal)
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.backgroundColor = .systemBlue
        addToCartButton.layer.cornerRadius = 12
        addToCartButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.addSubview(addToCartButton)

        NSLayoutConstraint.activate([
            // PRICE LABEL — сверху слева
            priceBottomLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            priceBottomLabel.leftAnchor.constraint(equalTo: bottomBar.leftAnchor, constant: 16),

            // ADD TO CART BUTTON — сверху справа
            addToCartButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 8),
            addToCartButton.rightAnchor.constraint(equalTo: bottomBar.rightAnchor, constant: -16),
            addToCartButton.widthAnchor.constraint(equalToConstant: 140),
            addToCartButton.heightAnchor.constraint(equalToConstant: 48),

            // ScrollView — выше bottomBar
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
    }

    // MARK: UPDATE UI
    private func updateUI(with product: Product) {

        nameLabel.text = product.name
        priceLabel.text = "\(product.price) ₽"
        descriptionLabel.text = product.description ?? "Нет описания"

        setupNutrition(product)

        loadImages(from: product.photos)
        
        priceBottomLabel.text = "\(product.price) ₽"
    }

    private func setupNutrition(_ product: Product) {

        nutritionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(String, String)] = [
            ("Ккал", "\(product.calories ?? 0)"),
            ("Белки", "\(product.proteins ?? 0) г"),
            ("Жиры", "\(product.fats ?? 0) г"),
            ("Углеводы", "\(product.carbohydrates ?? 0) г"),
            ("Вес", "\(product.weight ?? 0) г")
        ]

        for (title, value) in items {
            let container = UIView()

            let t = UILabel()
            t.text = title
            t.font = .systemFont(ofSize: 13)
            t.textAlignment = .center

            let v = UILabel()
            v.text = value
            v.font = .systemFont(ofSize: 17, weight: .bold)
            v.textAlignment = .center

            let stack = UIStackView(arrangedSubviews: [t, v])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 3
            stack.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor),
                stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                stack.leftAnchor.constraint(equalTo: container.leftAnchor),
                stack.rightAnchor.constraint(equalTo: container.rightAnchor)
            ])

            nutritionStack.addArrangedSubview(container)
        }
    }

    private func loadImages(from urls: [String]?) {

        let imageNames = (urls?.isEmpty == false ? urls! : ["cheesecake","latte","eclair"])

        images.removeAll()

        for item in imageNames {
            if item.starts(with: "http") {
                if let url = URL(string: item) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let img = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.images.append(img)
                                
                                self.pageControl.numberOfPages = self.images.count

                                self.isImagesBuilt = false  // пересобрать layout
                                self.view.setNeedsLayout()
                            }
                        }
                    }.resume()
                }
            } else {
                if let img = UIImage(named: item) {
                    images.append(img)
                }
            }
        }

        // Если все картинки локальные — обновляем сразу
        if !imageNames.contains(where: { $0.starts(with: "http") }) {
            pageControl.numberOfPages = images.count
            isImagesBuilt = false
            self.view.setNeedsLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isImagesBuilt, !images.isEmpty {
            setupImagesScroll()
            isImagesBuilt = true
        }
    }
    
    @objc func pageControlTapped(_ sender: UIPageControl) {
        currentIndex = sender.currentPage
        scrollToIndex(currentIndex)
    }

    private func setupImagesScroll() {
        imageScrollView.subviews.forEach { $0.removeFromSuperview() }

        let width = imageScrollView.frame.width
        let height = imageScrollView.frame.height

        imageScrollView.contentSize = CGSize(width: width * CGFloat(images.count), height: height)

        for (index, img) in images.enumerated() {
            let imageView = UIImageView(image: img)
            imageView.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageScrollView.addSubview(imageView)
        }

        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
    }
    
    @IBAction func buttonLeft(_ sender: UIButton) {
        if currentIndex > 0 {
            currentIndex -= 1
            scrollToIndex(currentIndex)
        }
    }

    @IBAction func buttonRight(_ sender: UIButton) {
        if currentIndex < images.count - 1 {
            currentIndex += 1
            scrollToIndex(currentIndex)
        }
    }
    
    private func scrollToIndex(_ index: Int) {
        let xOffset = CGFloat(index) * imageScrollView.frame.width
        imageScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        pageControl.currentPage = index
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        currentIndex = page
        pageControl.currentPage = page
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page
    }

    // MARK: API
    private func loadProduct() {
        guard let id = productId else { return }

        Task {
            do {
                let product = try await ProductDetailService.shared.fetchProduct(id: id)

                await MainActor.run {
                    self.updateUI(with: product)
                }

            } catch {
                print("Product detail error:", error.localizedDescription)
                // тут можно показать алерт
            }
        }
    }
}
