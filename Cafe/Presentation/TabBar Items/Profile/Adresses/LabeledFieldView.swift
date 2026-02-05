

import UIKit


final class LabeledFieldView: UIView {

    let titleLabel = UILabel()
    let textField: UITextField

    init(title: String, textField: UITextField) {
        self.textField = textField
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12            // было 14 → стало компактнее
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        backgroundColor = .secondarySystemBackground

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium) // меньше шрифт
        titleLabel.textColor = .secondaryLabel

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 16) // аккуратный размер текста
        textField.placeholder = nil

        addSubview(titleLabel)
        addSubview(textField)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),   // было 10
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2), // было 6
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6), // было -10

            heightAnchor.constraint(equalToConstant: 52) // 👈 ключевое: фиксированная компактная высота
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
