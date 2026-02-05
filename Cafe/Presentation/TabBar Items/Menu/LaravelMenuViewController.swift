import UIKit
import Supabase
import Foundation

struct MenuItem {
    let id: Int
    let name: String
    let price: Int
    let imageName: String
    var qty: Int = 0
}

class LaravelMenuViewController: UIViewController {
    private var images: [UIImage] = []
    private var collectionView: UICollectionView!
    
    private let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    private let itemSpacing: CGFloat = 12
    private let lineSpacing: CGFloat = 12
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    // Тут будут данные меню (пока мок)
    var items: [MenuItem] = [
       // MenuItem(name: "Капучино", price: 180, imageName: "cappuccino"),
       // MenuItem(name: "Латте", price: 190, imageName: "latte"),
//        MenuItem(name: "Эклер", price: 240, imageName: "eclair"),
//        MenuItem(name: "Чизкейк", price: 320, imageName: "cheesecake")
    ]
    
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
            self.view.setNeedsLayout()
        }
    }
    private func setupHideKeyboardOnTap() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
           tapGesture.cancelsTouchesInView = false // важно: позволяет тапать сквозь gesture recognizer
           view.addGestureRecognizer(tapGesture)
       }
    
    @objc private func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
           print("you tapped somewhere...");
       // let location = gesture.location(in: view)
       // let tappedView = view.hitTest(location, with: nil)
        view.endEditing(true)
       }
    private func loadData() {
        Task {
            do {
                async let productsTask = ProductsService.shared.fetchProducts()
                async let cartTask = CartService.shared.getCart()

                let products = try await productsTask
                let cartResponse = try await cartTask

                // qtyById: dessert_id -> qty
                let qtyById: [Int: Int] = Dictionary(
                    uniqueKeysWithValues: cartResponse.items.map { ($0.dessertId, $0.qty) }
                )

                let mapped: [MenuItem] = products.map { product in
                    MenuItem(
                        id: product.id,
                        name: product.name,
                        price: Int(product.price),
                        imageName: product.photos?[0] ?? "eclair",
                        qty: qtyById[product.id] ?? 0
                    )
                }

                await MainActor.run {
                    self.items = mapped
                    self.collectionView.reloadData()
                }

            } catch {
                print("Load menu/cart error:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Меню"
        view.backgroundColor = .white
        
        // Устанавливаем иконку для Tab Bar
        let forkSpoonImage = UIImage(systemName: "fork.knife") // SF Symbol "fork.knife"
        tabBarItem = UITabBarItem(title: "Меню", image: forkSpoonImage, selectedImage: forkSpoonImage)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cartDidChange(_:)),
                                               name: .cartDidChange,
                                               object: nil)
        setupHideKeyboardOnTap()
        setupCollection()
        setupConstraints()
        loadData()
        
    }
    
    @objc private func cartDidChange(_ notification: Notification) {
        guard let cart = notification.object as? CartDTO else { return }

        let qtyById: [Int: Int] = Dictionary(
            uniqueKeysWithValues: cart.items.map { ($0.dessertId, $0.qty) }
        )

        var changed: [IndexPath] = []

        for i in 0..<items.count {
            let newQty = qtyById[items[i].id] ?? 0
            if items[i].qty != newQty {
                items[i].qty = newQty
                changed.append(IndexPath(item: i, section: 0))
            }
        }

        guard !changed.isEmpty else { return }
        collectionView.reloadItems(at: changed)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Поле поиска
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Кнопка поиска
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 120),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }




    @objc private func searchButtonTapped() {
        //прячем клав
         view.endEditing(true)
        print("query:")
        print(searchTextField.text)
        print(searchTextField.text!.isEmpty)
        let query:String!;
        if(searchTextField.text!.isEmpty) {
            query = "*";
        }
        else {
            //зачем guard? надо прочитать
             query = searchTextField.text
            
                
        }
        
        Task {
            do {
                let products = try await ProductsService.shared.searchProducts(body: SearchDTO(query: query))
                print("Найдено товаров: \(products.count)")
                print(products)

                //добавляем products в массив
                //обновляем список товаров
                       let mapped: [MenuItem] = products.map { product in
                    MenuItem(
                        id: product.id,
                        name: product.name,
                        price: Int(product.price),
                        imageName: "eclair",
                       // qty: qtyById[product.id] ?? 0
                    )
                }


                  await MainActor.run {
                    self.items = mapped
                    self.collectionView.reloadData()
                }


            } catch {
                print("Ошибка поиска: \(error)")
            }
        }
    }
    private func setupCollection() {
    // Настраиваем текстовое поле
    searchTextField.placeholder = "Введите запрос..."
    searchTextField.borderStyle = .roundedRect
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchTextField)
    
    // Настраиваем кнопку
    searchButton.setTitle("Поиск", for: .normal)
    searchButton.backgroundColor = .systemBlue
    searchButton.setTitleColor(.white, for: .normal)
    searchButton.layer.cornerRadius = 10
    searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    searchButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchButton)

    // CollectionView
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
    layout.sectionInset = sectionInsets

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.register(LaravelMenuCell.self, forCellWithReuseIdentifier: "LaravelMenuCell")

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    // 🔥 ИСПРАВЛЕННЫЕ КОНСТРЕЙНТЫ
    NSLayoutConstraint.activate([
        // Поле поиска
        searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
        searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        searchTextField.heightAnchor.constraint(equalToConstant: 44),
        
        // Кнопка поиска
        searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
        searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        searchButton.widthAnchor.constraint(equalToConstant: 120),
        searchButton.heightAnchor.constraint(equalToConstant: 44),
        
        // CollectionView - ПОД кнопкой поиска
        collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 16),
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}
}

extension LaravelMenuViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2

        let width = collectionView.bounds.width
        let insets = sectionInsets.left + sectionInsets.right
        let totalSpacing = (columns - 1) * itemSpacing
        let itemWidth = floor((width - insets - totalSpacing) / columns)

        // высоту подгони под себя (чуть выше, чтобы текст+кнопки не давили картинку)
        let itemHeight = itemWidth * 1.1

        return CGSize(width: itemWidth, height: itemHeight)
    }
}

extension LaravelMenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LaravelMenuCell", for: indexPath) as! LaravelMenuCell
        cell.configure(item: items[indexPath.row])
        cell.parentViewController = self // если self — это UICollectionViewController / UIViewController
        return cell
    }
}
