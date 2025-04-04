//
//  WalletVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

typealias GroupOfTransactions = (date: Date, transactions: [TransactionModel])

protocol TransactionsViewDelegate: AnyObject {
    func updateTransactions()
}

class WalletVM {
    private let transactionsBatchSize = 20
    let transactionsService: TransactionsDataService
    let walletService: WalletsDataService
    let rateService: BitcoinRateService
    var mainWallet: WalletModel!
    var transactions: [GroupOfTransactions] = []
    weak var delegate: TransactionsViewDelegate? {
        didSet {
            delegate?.updateTransactions()
        }
    }
    var allTransactionsCount: Int {
        transactions.flatMap { $0.transactions }.count
    }
    
    /// Initializes the view model with required services.
    init(walletService: WalletsDataService, rateService: BitcoinRateService, transactionsService: TransactionsDataService) {
        self.walletService = walletService
        self.rateService = rateService
        self.transactionsService = transactionsService
        setup()
    }
    
    /// Sets up observer and loads initial wallet and transactions.
    private func setup() {
        transactionsService.addObserver(self)
        updateWallet()
        fetchNewTransactions()
    }
    
    /// Updates or creates the main wallet.
    private func updateWallet() {
        if let wallet = walletService.getWallets().first {
            self.mainWallet = wallet
        } else if let newWallet = walletService.createMainWallet() {
            self.mainWallet = newWallet
        }
    }
    
    /// Fetches the next batch of transactions.
    func fetchNewTransactions() {
        let newTransactions = transactionsService.fetchTransactionsBatch(
            for: mainWallet,
            offset: allTransactionsCount,
            limit: transactionsBatchSize
        )
        if !newTransactions.isEmpty {
            mergeNewBatch(newTransactions)
        }
    }
    
    /// Merges a new batch of transactions into existing groups.
    private func mergeNewBatch(_ newTransactions: [TransactionModel]) {
        let groupedTransactions = Dictionary(grouping: newTransactions,
                                             by: { $0.date.startOfDay() })
        var mergedTransactions = Dictionary(uniqueKeysWithValues: transactions)
        mergedTransactions.merge(groupedTransactions) { $0 + $1 }
        self.transactions = mergedTransactions
            .sorted(by: { $0.key > $1.key })
            .map { ($0.key, $0.value) }
        delegate?.updateTransactions()
    }
    
    /// Adds a newly created transaction to the top of the list.
    private func addNewTransaction(_ transaction: TransactionModel) {
        if transactions.first?.date == transaction.date.startOfDay() {
            transactions[0].transactions.insert(transaction, at: 0)
        } else {
            let newGroup = GroupOfTransactions(transaction.date.startOfDay(), [transaction])
            transactions.insert(newGroup, at: 0)
        }
        delegate?.updateTransactions()
    }
    
    /// Returns all transactions for a specific date.
    func transactions(for date: Date) -> [TransactionModel] {
        if let transactions = transactions.first(where: { $0.date == date })?.transactions {
            return transactions
        } else {
            return []
        }
    }
    
    /// Removes observer on deinitialization.
    deinit {
        transactionsService.removeObserver(self)
    }
}

extension WalletVM: TransactionsOberver {
    /// Handles transaction addition from the observer.
    func addedTransaction(_ transaction: TransactionModel) {
        guard mainWallet.walletId == transaction.walletId else { return }
        addNewTransaction(transaction)
        updateWallet()
    }
}
