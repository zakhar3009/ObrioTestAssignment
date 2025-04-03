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
    
    init(walletService: WalletsDataService, rateService: BitcoinRateService, transactionsService: TransactionsDataService) {
        self.walletService = walletService
        self.rateService = rateService
        self.transactionsService = transactionsService
        transactionsService.addObserver(self)
        setupWallet()
        fetchNewTransactions()
    }
    
    private func setup() {
        transactionsService.addObserver(self)
        setupWallet()
        fetchNewTransactions()
    }
    
    private func setupWallet() {
        if let wallet = walletService.getWallets().first {
            self.mainWallet = wallet
        } else if let newWallet = walletService.createMainWallet() {
            self.mainWallet = newWallet
        }
    }
    
    func fetchNewTransactions() {
        let transactionsCount = transactions.flatMap { $0.transactions }.count
        let newTransactions = transactionsService.fetchTransactionsBatch(
            for: mainWallet,
            offset: transactionsCount,
            limit: transactionsBatchSize
        )
        if !newTransactions.isEmpty {
            mergeNewTransactions(newTransactions)
        }
    }
    
    private func mergeNewTransactions(_ newTransactions: [TransactionModel]) {
        let groupedTransactions = groupTransactions(newTransactions)
        let previousGroupCount = transactions.count
        var mergedTransactions = Dictionary(uniqueKeysWithValues: transactions)
        mergedTransactions.merge(groupedTransactions) { current, new in current + new }
        transactions = mergedTransactions.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
        let updateLayout = transactions.count > previousGroupCount
        notifyDelegate(updateLayout: updateLayout)
    }
    
    private func notifyDelegate(updateLayout: Bool) {
        delegate?.updateTransactions()
    }
    
    private func groupTransactions(_ transactions: [TransactionModel]) -> [Date: [TransactionModel]] {
        let calendar = Calendar.current
        return Dictionary(grouping: transactions, by: { calendar.startOfDay(for: $0.date) })
    }
    
    func transactions(for date: Date) -> [TransactionModel] {
        guard let transactions = transactions.first(where: { $0.date == date })?.transactions else {
            return []
        }
        return transactions
    }
    
    deinit {
        transactionsService.removeObserver(self)
    }
}

extension WalletVM: TransactionsOberver {
    func addedTransaction(_ transaction: TransactionModel) {
        guard mainWallet.walletId == transaction.walletId else { return }
        mergeNewTransactions([transaction])
    }
}
