import UIKit
import Supabase
import Foundation

struct Product: Codable {
    let id: Int
    let price: Double
    let name: String
}

struct ProductsResponse: Codable {
    let data: [Product]
}

class LaravelMenuCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let cartImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
        backgroundColor = .white

        // ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12

        // Title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular) // уменьшили и сделали не жирным
        titleLabel.numberOfLines = 3 // позволяем до 3 строк
        titleLabel.textAlignment = .center

        // Кнопка с ценой
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        addButton.layer.cornerRadius = 8
        addButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        // Иконка корзины справа
        cartImageView.image = UIImage(systemName: "cart.fill")
        cartImageView.tintColor = .white
        cartImageView.contentMode = .scaleAspectFit
        cartImageView.translatesAutoresizingMaskIntoConstraints = false

        // Стек с картинкой и заголовком
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        contentView.addSubview(addButton)
        addButton.addSubview(cartImageView)

        stack.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.55),

            addButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            addButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10),

            cartImageView.trailingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: -8),
            cartImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            cartImageView.widthAnchor.constraint(equalToConstant: 20),
            cartImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(item: MenuItem) {
        titleLabel.text = item.name
        addButton.setTitle("\(item.price) ₽", for: .normal)
        imageView.image = UIImage(named: item.imageName)
    }
}

class LaravelMenuViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    // Тут будут данные меню (пока мок)
    var items: [MenuItem] = [
        MenuItem(name: "Капучино", price: 180, imageName: "cappuccino"),
        MenuItem(name: "Латте", price: 190, imageName: "latte"),
//        MenuItem(name: "Эклер", price: 240, imageName: "eclair"),
//        MenuItem(name: "Чизкейк", price: 320, imageName: "cheesecake")
    ]
    
    func fetchLaravelProducts() async {
           print("fetching laravel users!!!!!")
           let url = URL(string: "http://localhost:8000/products")! // ← Use localhost here
           print(url)
           
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("application/json", forHTTPHeaderField: "Accept")
           
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error: \(error)")
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   print("Status code: \(httpResponse.statusCode)")
               }
               var displayText = ""
               if let data = data {
                   
                   do {
                       // Декодируем данные в массив продуктов
                       let productsResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
                       let products = productsResponse.data
                              for product in products {
                                  displayText += "ID: \(product.id) \nName: \(product.name) \nPrice: \(product.price)\n\n"
                                  print("ID: \(product.id), Name: \(product.name), Price: \(product.price)")
                                  self.items.append(MenuItem(name: product.name, price: Int(product.price), imageName: "eclair"))
                              }
                               } catch {
                                   print("JSON parsing error: \(error)")
                               }
                   
                  
                   
                   // Обновляем UI на главном потоке
                   DispatchQueue.main.async {
                       self.collectionView.reloadData()
                   }
                   print("Data received: \(String(data: data, encoding: .utf8) ?? "Unable to parse")")
               }
           }
           task.resume() // ← Don't forget to call resume()!
       }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Меню"
        view.backgroundColor = .white
        

        setupCollection()
        
        Task {
            await fetchLaravelProducts()
        }
    }
    
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width/2 - 20, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self

        collectionView.register(LaravelMenuCell.self, forCellWithReuseIdentifier: "LaravelMenuCell")

        view.addSubview(collectionView)
        collectionView.frame = view.bounds
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
        return cell
    }
}
