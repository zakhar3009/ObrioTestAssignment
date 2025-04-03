//
//  CreationController.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//
import UIKit

class TransactionCreationViewController: UIViewController {
    weak var coordinator: WalletCoordinator?
    private var vm: TransactionCreationVM!
    private var selectionView: CategorySelectionView!
    private var amountTextField: UITextField!
    private var createButton: UIButton!
    private var inputTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupLayout()
    }
    
    func configure(with vm: TransactionCreationVM) {
        self.vm = vm
        vm.delegate = self
    }
    
    private func setupUI() {
        title = "Add transaction"
        setupInputTitle()
        setupAmountInput()
        setupSelectionView()
        setupCreateButton()
    }
    
    private func setupInputTitle() {
        inputTitle = UILabel()
        inputTitle.translatesAutoresizingMaskIntoConstraints = false
        inputTitle.textAlignment = .left
        inputTitle.text = "Amount"
        inputTitle.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(inputTitle)
    }
    
    private func setupAmountInput() {
        amountTextField = UITextField()
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        view.addSubview(amountTextField)
    }
    
    private func setupSelectionView() {
        selectionView = CategorySelectionView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.configure(with: vm.selectionVM)
        view.addSubview(selectionView)
    }
    
    private func setupCreateButton() {
        createButton = UIButton(type: .system)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle("Create", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        createButton.backgroundColor = .systemGray5
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.isEnabled = false
        view.addSubview(createButton)
    }
    
    @objc
    private func createButtonTapped() {
        vm.createTransaction()
        coordinator?.back()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            inputTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            inputTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputTitle.heightAnchor.constraint(equalToConstant: 20),
        ])
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: inputTitle.bottomAnchor, constant: 12),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
        selectionView.sizeToFit()
        NSLayoutConstraint.activate([
            selectionView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        NSLayoutConstraint.activate([
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension TransactionCreationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        vm.setNewInput(textField.text ?? "")
    }
}

extension TransactionCreationViewController: TransactionCreationVMDelegate {
    func updateEnabledCreation(_ enabled: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.createButton.isEnabled = enabled
            self.createButton.backgroundColor = enabled ? .systemBlue : .systemGray5
        }
    }
    
    func notEnoughFunds() {
        let alert = UIAlertController(title: "Not enough funds",
                                      message: "Please add funds to your wallet to complete this transaction.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
