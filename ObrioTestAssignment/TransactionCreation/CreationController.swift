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
    private lazy var selectionView: CategorySelectionView = {
        let selection = CategorySelectionView()
        selection.translatesAutoresizingMaskIntoConstraints = false
        selection.configure(with: vm.selectionVM)
        return selection
    }()
    private lazy var amountTextField: UITextField = {
        let input = UITextField()
        input.translatesAutoresizingMaskIntoConstraints = false
        input.placeholder = "Enter amount"
        input.borderStyle = .roundedRect
        input.keyboardType = .numbersAndPunctuation
        input.delegate = self
        return input
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()
    private lazy var inputTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .left
        title.text = "Amount"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        return title
    }()
    
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
        view.addSubview(inputTitle)
        view.addSubview(amountTextField)
        view.addSubview(selectionView)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
