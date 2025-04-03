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
    private let balanceTitle = UILabel()
    private let scrollView = UIScrollView()
    private let rateLabel = UILabel()
    private let balanceValue = UILabel()
    private let depositButton = UIButton(type: .system)
    private let addTransactionButton = UIButton()
    
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
        setupRateLabel()
        setupBalanceTitle()
        setupBalanceValue()
        setupDepositButton()
        setupAddTransactionButton()
    }
    
    private func setupRateLabel() {
        rateLabel.text = "1 BTC = ???"
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.font = UIFont.systemFont(ofSize: 16)
        rateLabel.textColor = .gray
        rateLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(rateLabel)
    }
    
    private func setupBalanceTitle() {
        balanceTitle.text = "Balance"
        balanceTitle.translatesAutoresizingMaskIntoConstraints = false
        balanceTitle.font = UIFont.boldSystemFont(ofSize: 20)
        balanceTitle.textColor = .black
        self.contentView.addSubview(balanceTitle)
    }
    
    private func setupBalanceValue() {
        balanceValue.text = "-"
        balanceValue.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.font = UIFont.boldSystemFont(ofSize: 28)
        balanceValue.textColor = .black
        balanceValue.adjustsFontSizeToFitWidth = true
        balanceValue.minimumScaleFactor = 0.5
        self.contentView.addSubview(balanceValue)
    }
    
    private func setupDepositButton() {
        depositButton.setTitle("+", for: .normal)
        depositButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        depositButton.addTarget(self, action: #selector(showDepositPopup), for: .touchUpInside)
        self.contentView.addSubview(depositButton)
    }
    
    private func setupAddTransactionButton() {
        addTransactionButton.setTitle("Add Transaction", for: .normal)
        addTransactionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.backgroundColor = .systemBlue
        addTransactionButton.layer.cornerRadius = 12
        addTransactionButton.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
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

