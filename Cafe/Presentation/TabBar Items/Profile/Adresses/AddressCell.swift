import UIKit

final class AddressCell: UITableViewCell {

    private let checkboxButton = UIButton(type: .system)
    var onCheckboxTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onCheckboxTap = nil
        checkboxButton.setImage(nil, for: .normal)
    }

    private func setup() {
        checkboxButton.tintColor = .systemBlue
        checkboxButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        checkboxButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        // ✅ галка справа (как системный accessory)
        accessoryView = checkboxButton
        accessoryType = .none
    }

    @objc private func checkboxTapped() {
        onCheckboxTap?()
    }

    func setChecked(_ checked: Bool) {
        let name = checked ? "checkmark.square.fill" : "square"
        checkboxButton.setImage(UIImage(systemName: name), for: .normal)
    }
}
