//
//  TextFieldCell.swift
//  Cafe
//
//  Created by Антон Абалуев on 05.01.2026.
//

import UIKit

final class TextFieldCell: UITableViewCell {

    static let reuseId = "TextFieldCell"

    private let titleLabel = UILabel()
    private let textField = UITextField()
    private var onChange: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textField.font = .systemFont(ofSize: 16)
        textField.textAlignment = .right
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            textField.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        title: String,
        value: String,
        keyboard: UIKeyboardType,
        autocap: UITextAutocapitalizationType,
        onChange: @escaping (String) -> Void
    ) {
        titleLabel.text = title
        textField.text = value
        textField.keyboardType = keyboard
        textField.autocapitalizationType = autocap
        textField.autocorrectionType = .no
        self.onChange = onChange
    }

    @objc private func textChanged() {
        onChange?(textField.text ?? "")
    }
}
