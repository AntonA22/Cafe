
import UIKit
import CoreLocation
import YandexMapsMobile

final class AddAddressViewController: UIViewController {

    var onSave: ((Address) -> Void)?
    
    private var prefillAddress: Address?

    convenience init(edit address: Address) {
        self.init()
        self.prefillAddress = address
    }

    private let topPanel = UIView()
    // MARK: UI

    private let titleField = UITextField()

    private let entranceField = UITextField()     // подъезд
    private let intercomField = UITextField()     // домофон
    private let floorField = UITextField()        // этаж
    private let flatField = UITextField()         // офис/квартира

    private let detailsStack = UIStackView()

    private let suggestionsTable = UITableView(frame: .zero, style: .plain)
    private var suggestions: [YMKSuggestItem] = []

    private var mapView: YMKMapView!
    private var map: YMKMap { mapView.mapWindow.map }

    // MARK: Search (Yandex)

    private lazy var searchManager: YMKSearchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    private lazy var suggestSession: YMKSearchSuggestSession = searchManager.createSuggestSession()
    private var searchSession: YMKSearchSession?

    // MARK: Search UI like example

    private lazy var resultsTableController = ResultsTableController()
    private lazy var searchController = UISearchController(searchResultsController: resultsTableController)

    // MARK: Picked

    private var pickedPoint: YMKPoint?
    private var pickedAddressText: String?

    private lazy var mapInputListener = MapInputListener(owner: self)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = (prefillAddress == nil) ? "Новый адрес" : "Редактировать адрес"
        view.backgroundColor = .systemBackground

        setupNav()
        setupMap()
        setupUI()
        setupSearchController()

        if let a = prefillAddress {
            title = "Редактировать адрес"
            applyPrefill(a)
        } else {
            title = "Новый адрес"
            moveToStartPointMoscow()
        }
    }
    
    private func applyPrefill(_ a: Address) {
        // имя
        titleField.text = a.title

        // адрес в поиск
        searchController.searchBar.text = a.baseAddress
        pickedAddressText = a.baseAddress

        // детали
        entranceField.text = a.entrance
        intercomField.text = a.intercom
        floorField.text = a.floor
        flatField.text = a.flat

        // точка
        let point = YMKPoint(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
        pickedPoint = point
        showPin(at: point)
        centerMap(on: point)
    }

    // MARK: Setup

    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }

    private func setupMap() {
        mapView = YMKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        map.addInputListener(with: mapInputListener)
    }

    private func setupUI() {
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        // 2) настрой поля
        titleField.clearButtonMode = .whileEditing
        titleField.returnKeyType = .done
        titleField.delegate = self

        [entranceField, intercomField, floorField, flatField].forEach {
            $0.clearButtonMode = .whileEditing
            $0.returnKeyType = .done
            $0.delegate = self
        }
        floorField.keyboardType = .numberPad

        // 3) карточки
        let titleBox = LabeledFieldView(title: "Название", textField: titleField)
        let entranceBox = LabeledFieldView(title: "Подъезд", textField: entranceField)
        let intercomBox = LabeledFieldView(title: "Домофон", textField: intercomField)
        let floorBox = LabeledFieldView(title: "Этаж", textField: floorField)
        let flatBox = LabeledFieldView(title: "Офис/квартира", textField: flatField)

        let row1 = UIStackView(arrangedSubviews: [entranceBox, intercomBox])
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: [floorBox, flatBox])
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detailsStack.addArrangedSubview(titleBox)
        detailsStack.addArrangedSubview(row1)
        detailsStack.addArrangedSubview(row2)

        // 2) Панель сверху
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        topPanel.backgroundColor = .secondarySystemBackground
        topPanel.layer.cornerRadius = 16
        topPanel.clipsToBounds = true

        topPanel.addSubview(detailsStack)
        view.addSubview(topPanel)

        // 3) Таблица подсказок — прямо под панелью (поверх карты)
        suggestionsTable.translatesAutoresizingMaskIntoConstraints = false
        suggestionsTable.dataSource = self
        suggestionsTable.delegate = self
        suggestionsTable.register(UITableViewCell.self, forCellReuseIdentifier: "SugCell")
        suggestionsTable.isHidden = true
        suggestionsTable.layer.cornerRadius = 12
        suggestionsTable.clipsToBounds = true
        view.addSubview(suggestionsTable)

        NSLayoutConstraint.activate([
            // Панель сверху
            topPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            detailsStack.topAnchor.constraint(equalTo: topPanel.topAnchor, constant: 12),
            detailsStack.leadingAnchor.constraint(equalTo: topPanel.leadingAnchor, constant: 12),
            detailsStack.trailingAnchor.constraint(equalTo: topPanel.trailingAnchor, constant: -12),
            detailsStack.bottomAnchor.constraint(equalTo: topPanel.bottomAnchor, constant: -12),

            // Таблица подсказок под панелью
            suggestionsTable.topAnchor.constraint(equalTo: topPanel.bottomAnchor, constant: 8),
            suggestionsTable.leadingAnchor.constraint(equalTo: topPanel.leadingAnchor),
            suggestionsTable.trailingAnchor.constraint(equalTo: topPanel.trailingAnchor),
            suggestionsTable.heightAnchor.constraint(equalToConstant: 260),

            // Карта — начинается под панелью (а не под таблицей!)
            mapView.topAnchor.constraint(equalTo: topPanel.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearchController() {
        // как в примере
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск адреса"

        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = false

        resultsTableController.tableView.delegate = self
    }

    private func moveToStartPointMoscow() {
        let moscow = YMKPoint(latitude: 55.753284, longitude: 37.622034)
        let pos = YMKCameraPosition(target: moscow, zoom: 13.0, azimuth: 0, tilt: 0)
        map.move(with: pos, animation: YMKAnimation(type: .smooth, duration: 0.4))
    }

    // MARK: Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else { return showAlert("Введите название") }

        guard let point = pickedPoint else {
            return showAlert("Выберите адрес через поиск (или тапните по карте).")
        }

        let base = (pickedAddressText ?? searchController.searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !base.isEmpty else { return showAlert("Не удалось определить адрес") }

        func clean(_ tf: UITextField) -> String? {
            let t = (tf.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : t
        }

        let dto = AddressUpsertDTO(
            title: title,
            baseAddress: base,
            entrance: clean(entranceField),
            intercom: clean(intercomField),
            floor: clean(floorField),
            flat: clean(flatField),
            latitude: point.latitude,
            longitude: point.longitude
        )

        navigationItem.rightBarButtonItem?.isEnabled = false

        Task { [weak self] in
            guard let self else { return }
            do {
                let savedDTO: AddressDTO

                if let existing = self.prefillAddress {
                    // UPDATE
                    savedDTO = try await AddressService.shared.updateAddress(id: existing.id, dto: dto)
                } else {
                    // CREATE
                    savedDTO = try await AddressService.shared.createAddress(dto)
                }

                let savedAddress = Address(dto: savedDTO)

                await MainActor.run {
                    self.onSave?(savedAddress)
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    //self.showAlert("Не удалось сохранить адрес")
                    self.showAlert(error.localizedDescription)    
                    print("save address error:", error)
                }
            }
        }
    }
    
    private func buildDetailsString() -> String {
        func clean(_ tf: UITextField) -> String {
            (tf.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var parts: [String] = []

        let entrance = clean(entranceField)
        if !entrance.isEmpty { parts.append("подъезд \(entrance)") }

        let intercom = clean(intercomField)
        if !intercom.isEmpty { parts.append("домофон \(intercom)") }

        let floor = clean(floorField)
        if !floor.isEmpty { parts.append("этаж \(floor)") }

        let flat = clean(flatField)
        if !flat.isEmpty { parts.append(flat) }

        return parts.joined(separator: ", ")
    }

    fileprivate func didTapMap(at point: YMKPoint) {
        suggestionsTable.isHidden = true
        searchController.isActive = false
        view.endEditing(true)

        pickedPoint = point
        pickedAddressText = searchController.searchBar.text

        showPin(at: point)
        centerMap(on: point)
        
        reverseGeocode(point: point)
    }
    
    private func reverseGeocode(point: YMKPoint) {
        let options = YMKSearchOptions()
        options.resultPageSize = 1
        // можно оставить дефолт, но если хочешь только адреса:
        // options.searchTypes = .geo

        searchSession?.cancel()
        searchSession = searchManager.submit(
            with: point,
            zoom: NSNumber(value: map.cameraPosition.zoom),
            searchOptions: options
        ) { [weak self] response, error in
            guard let self else { return }
            guard error == nil, let response else { return }

            let firstObj = response.collection.children.compactMap { $0.obj }.first
            guard let geoObject = firstObj else { return }

            let formatted = Self.formattedAddress(from: geoObject)
            let textToShow = formatted.isEmpty ? (geoObject.name ?? "") : formatted

            self.pickedAddressText = textToShow
            self.searchController.searchBar.text = textToShow
        }
    }

    // MARK: Suggest / Search

    private func submitSuggest(text: String) {
        let vr = map.visibleRegion
        let window = YMKBoundingBox(southWest: vr.bottomLeft, northEast: vr.topRight)

        let options = YMKSuggestOptions(
            suggestTypes: [.biz, .geo, .transit],
            userPosition: nil,
            suggestWords: true,
            strictBounds: false
        )

        suggestSession.suggest(
            withText: text,
            window: window,
            suggestOptions: options
        ) { [weak self] response, error in
            guard let self else { return }

            if error != nil {
                self.suggestions = []
                self.suggestionsTable.reloadData()
                self.suggestionsTable.isHidden = true
                return
            }

            self.suggestions = Array((response?.items ?? []).prefix(8))
            self.suggestionsTable.reloadData()
            self.suggestionsTable.isHidden = self.suggestions.isEmpty

            // обновим и таблицу результатов в стиле примера
            self.resultsTableController.items = self.suggestions
            self.resultsTableController.tableView.reloadData()
        }
    }

    private func selectSuggest(_ item: YMKSuggestItem) {
        suggestionsTable.isHidden = true
        view.endEditing(true)

        // как в примере — закрываем поиск, но оставляем текст
        searchController.searchBar.text = item.displayText ?? item.title.text
        searchController.isActive = false

        if item.action == .search, let uri = item.uri {
            submitUriSearch(uri: uri)
        } else {
            let text = item.searchText ?? item.displayText ?? ""
            guard !text.isEmpty else { return }
            startSearch(text: text)
        }
    }

    private func startSearch(text: String) {
        let geometry = YMKVisibleRegionUtils.toPolygon(with: map.visibleRegion)

        let options = YMKSearchOptions()
        options.resultPageSize = 1

        searchSession?.cancel()
        searchSession = searchManager.submit(
            withText: text,
            geometry: geometry,
            searchOptions: options
        ) { [weak self] response, error in
            self?.handleSearchResponse(response: response, error: error)
        }
    }

    private func submitUriSearch(uri: String) {
        let options = YMKSearchOptions()
        options.resultPageSize = 1

        searchSession?.cancel()
        searchSession = searchManager.searchByURI(
            withUri: uri,
            searchOptions: options
        ) { [weak self] response, error in
            self?.handleSearchResponse(response: response, error: error)
        }
    }

    private func handleSearchResponse(response: YMKSearchResponse?, error: Error?) {
        guard error == nil, let response else { return }

        let firstObj = response.collection.children.compactMap { $0.obj }.first
        guard let geoObject = firstObj,
              let point = geoObject.geometry.first?.point else { return }

        pickedPoint = point
        let formatted = Self.formattedAddress(from: geoObject)
        pickedAddressText = formatted.isEmpty ? (searchController.searchBar.text ?? "") : formatted
        searchController.searchBar.text = pickedAddressText

        showPin(at: point)
        centerMap(on: point)
    }

    private func showPin(at point: YMKPoint) {
        map.mapObjects.clear()
        let placemark = map.mapObjects.addPlacemark(with: point)
        let image = UIImage(systemName: "mappin.circle.fill")?
            .withTintColor(view.tintColor, renderingMode: .alwaysOriginal)
        if let image { placemark.setIconWith(image) }
    }

    private func centerMap(on point: YMKPoint) {
        let pos = YMKCameraPosition(target: point, zoom: max(map.cameraPosition.zoom, 15), azimuth: 0, tilt: 0)
        map.move(with: pos, animation: YMKAnimation(type: .smooth, duration: 0.35))
    }

    private static func formattedAddress(from geoObject: YMKGeoObject) -> String {
        if let toponym = geoObject.metadataContainer
            .getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata {
            return toponym.address.formattedAddress
        }

        if let business = geoObject.metadataContainer
            .getItemOf(YMKSearchBusinessObjectMetadata.self) as? YMKSearchBusinessObjectMetadata {
            let name = business.name
            let addr = business.address.formattedAddress
            if !addr.isEmpty { return "\(name), \(addr)" }
            return name
        }

        return geoObject.name ?? ""
    }

    private func showAlert(_ message: String) {
        let ac = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UISearchBar delegates (как в примере)

extension AddAddressViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) { }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // при вводе: показываем подсказки
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard text.count >= 2 else {
            suggestions = []
            suggestionsTable.reloadData()
            suggestionsTable.isHidden = true
            resultsTableController.items = []
            resultsTableController.tableView.reloadData()
            suggestSession.reset()
            return
        }

        submitSuggest(text: text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        startSearch(text: text)
        searchController.isActive = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        suggestionsTable.isHidden = true
        if case .some = pickedPoint {
            // ок
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - Suggestions overlay table (можешь убрать и оставить только resultsTableController, но так ближе к твоему UI)

extension AddAddressViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SugCell", for: indexPath)
        let item = suggestions[indexPath.row]

        var cfg = cell.defaultContentConfiguration()
        cfg.text = item.title.text
        cfg.secondaryText = item.subtitle?.text
        cell.contentConfiguration = cfg

        return cell
    }

}

// MARK: - results controller like example

fileprivate final class ResultsTableController: UITableViewController {
    private let cellIdentifier = "cellIdentifier"
    var items: [YMKSuggestItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        var cfg = cell.defaultContentConfiguration()
        let item = items[indexPath.row]
        cfg.text = item.title.text
        cfg.secondaryText = item.subtitle?.text
        cell.contentConfiguration = cfg

        return cell
    }
}

// MARK: - table delegate for results controller

extension AddAddressViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === resultsTableController.tableView {
            tableView.deselectRow(at: indexPath, animated: true)
            guard indexPath.row < resultsTableController.items.count else { return }
            selectSuggest(resultsTableController.items[indexPath.row])
        }
    }
}

// MARK: - Map input listener

private final class MapInputListener: NSObject, YMKMapInputListener {
    weak var owner: AddAddressViewController?

    init(owner: AddAddressViewController) {
        self.owner = owner
    }

    func onMapTap(with map: YMKMap, point: YMKPoint) {
        owner?.didTapMap(at: point)
    }

    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
        owner?.didTapMap(at: point)
    }
}
