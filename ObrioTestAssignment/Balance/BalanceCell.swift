//
//  TransactionsHeaderCell.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import UIKit

protocol BalanceCellDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
    func goToCreation()
}

class BalanceCell: UICollectionViewCell {
    static let reuseIdentifier = "BalanceCell"
    private var vm: BalanceVM? = nil
    weak var delegate: BalanceCellDelegate?
    private lazy var balanceTitle: UILabel = {
        let label = UILabel()
        label.text = "Balance"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    private lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.text = "1 BTC = ???"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var balanceValue: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    private lazy var depositButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showDepositPopup), for: .touchUpInside)
        return button
    }()
    private lazy var addTransactionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Transaction", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(vm: BalanceVM, delegate: BalanceCellDelegate) {
        self.vm = vm
        self.vm?.delegate = self
        self.delegate = delegate
    }
    
    private func setupUi() {
        self.contentView.addSubview(rateLabel)
        self.contentView.addSubview(balanceTitle)
        self.contentView.addSubview(balanceValue)
        self.contentView.addSubview(depositButton)
        self.contentView.addSubview(addTransactionButton)
    }
    
    private func setupLayout() {
        rateLabel.sizeToFit()
        NSLayoutConstraint.activate([
            rateLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            rateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16)
        ])
        NSLayoutConstraint.activate([
            balanceTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            balanceTitle.topAnchor.constraint(equalTo: self.rateLabel.bottomAnchor, constant: 16),
            balanceTitle.widthAnchor.constraint(equalToConstant: 100),
            balanceTitle.heightAnchor.constraint(equalToConstant: 20)
        ])
        NSLayoutConstraint.activate([
            balanceValue.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            balanceValue.topAnchor.constraint(equalTo: self.balanceTitle.bottomAnchor, constant: 12),
            balanceValue.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            balanceValue.heightAnchor.constraint(equalToConstant: 50)
        ])
        NSLayoutConstraint.activate([
            depositButton.leadingAnchor.constraint(equalTo: self.balanceValue.trailingAnchor, constant: 12),
            depositButton.topAnchor.constraint(equalTo: self.balanceValue.topAnchor, constant: 0),
            depositButton.widthAnchor.constraint(equalToConstant: 44),
            depositButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        NSLayoutConstraint.activate([
            addTransactionButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            addTransactionButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            addTransactionButton.topAnchor.constraint(equalTo: self.balanceValue.bottomAnchor, constant: 12),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    private func addTransactionTapped() {
        delegate?.goToCreation()
    }
    
    @objc
    private func showDepositPopup() {
        let alert = UIAlertController(title: "Enter amount for deposit", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .numberPad
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alert, weak self] _ in
            if let input = alert?.textFields?.first?.text,
               let amount = self?.vm?.validatedDeposit(from: input) {
                self?.vm?.addDeposit(amount)
            } else {
                self?.showInvalidInputAlert()
            }
        }
        alert.addAction(submitAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        self.delegate?.presentAlert(alert)
    }
    
    private func showInvalidInputAlert() {
        let alert = UIAlertController(title: "Invalid input", message: "Please enter a valid amount", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.delegate?.presentAlert(alert)
    }
}

extension BalanceCell: BalanceVMDelegate {
    func updateRateLabel(_ value: String) {
        self.rateLabel.text = value
    }
    
    func updateBalanceLabel(_ value: String) {
        self.balanceValue.text = value
    }
}

