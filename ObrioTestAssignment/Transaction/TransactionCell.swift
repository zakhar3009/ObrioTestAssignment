//
//  TransactionCell.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import UIKit

final class TransactionCell: UICollectionViewCell {
    static let reuseIdentifier = "TransactionCell"
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(vm: TransactionCellVM) {
        dateLabel.text = vm.formattedDate
        categoryLabel.text = vm.category
        amountLabel.text = vm.amount
        amountLabel.textColor = color(for: vm.transaction)
    }
    
    private func setupUI() {
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(categoryLabel)
        self.contentView.addSubview(amountLabel)
    }
    
    
    private func setupLayout() {
        dateLabel.sizeToFit()
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
            dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
        ])
        categoryLabel.sizeToFit()
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 12),
            categoryLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
        ])
        amountLabel.sizeToFit()
        NSLayoutConstraint.activate([
            amountLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func color(for transaction: TransactionModel) -> UIColor {
        switch transaction.type {
        case .deposit:
            UIColor.systemGreen
        case .expense:
            UIColor.systemRed
        }
    }
}
