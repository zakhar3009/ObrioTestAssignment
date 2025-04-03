//
//  TransactionCreationVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import Foundation

protocol TransactionCreationVMDelegate: AnyObject {
    func updateEnabledCreation(_ enabled: Bool)
}

class TransactionCreationVM {
    private let wallet: WalletModel
    private var amountInput = ""
    private var selectedCategory: TransactionCategories?
    private let transactionService: TransactionsDataService
    private var enabledCreation = false
    let selectionVM = CategorySelectionVM()
    weak var delegate: TransactionCreationVMDelegate?
    
    init(transactionService: TransactionsDataService, wallet: WalletModel) {
        self.transactionService = transactionService
        self.wallet = wallet
        selectionVM.selectionDelegate = self
    }
    
    func setNewInput(_ input: String) {
        amountInput = input
        updateEnabledCreation()
    }
    
    private func updateEnabledCreation() {
        if let amount = Decimal(string: amountInput), amount > 0, selectedCategory != nil {
            delegate?.updateEnabledCreation(true)
        } else {
            delegate?.updateEnabledCreation(false)
        }
    }
    
    func createTransaction() {
        guard let amount = Decimal(string: amountInput), let category = selectedCategory else { return }
        let transaction = TransactionModel(
            date: Date(),
            amount: amount,
            category: category,
            walletId: wallet.walletId,
            type: .expense)
        transactionService.add(transaction)
    }
}

extension TransactionCreationVM: CategorySelectionUpdateDelegate {
    func categoryUpdated() {
        selectedCategory = selectionVM.selectedCategory
        updateEnabledCreation()
    }
}
