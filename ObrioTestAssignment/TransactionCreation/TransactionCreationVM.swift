//
//  TransactionCreationVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import Foundation

protocol TransactionCreationVMDelegate: AnyObject {
    func updateEnabledCreation(_ enabled: Bool)
    func notEnoughFunds()
}

class TransactionCreationVM {
    private let wallet: WalletModel
    private var amountInput = ""
    private var selectedCategory: TransactionCategories?
    private let transactionService: TransactionsDataService
    private var enabledCreation = false
    let selectionVM = CategorySelectionVM()
    weak var delegate: TransactionCreationVMDelegate?
    
    /// Initializes the view model with services and wallet.
    init(transactionService: TransactionsDataService, wallet: WalletModel) {
        self.transactionService = transactionService
        self.wallet = wallet
        selectionVM.selectionDelegate = self
    }
    
    /// Sets new input for the amount field.
    func setNewInput(_ input: String) {
        amountInput = input
        updateEnabledCreation()
    }
    
    /// Enables or disables transaction creation based on input and category.
    private func updateEnabledCreation() {
        if let amount = Decimal(string: amountInput), amount > 0, selectedCategory != nil {
            delegate?.updateEnabledCreation(true)
        } else {
            delegate?.updateEnabledCreation(false)
        }
    }
    
    /// Creates a transaction if validation passes.
    func createTransaction() {
        guard let amount = Decimal(string: amountInput), let category = selectedCategory else { return }
        if wallet.balance < amount {
            delegate?.notEnoughFunds()
        } else {
            let transaction = TransactionModel(
                date: Date(),
                amount: amount,
                category: category,
                walletId: wallet.walletId,
                type: .expense)
            transactionService.add(transaction)
        }
    }
}

extension TransactionCreationVM: CategorySelectionUpdateDelegate {
    /// Updates selected category and creation state.
    func categoryUpdated() {
        selectedCategory = selectionVM.selectedCategory
        updateEnabledCreation()
    }
}
