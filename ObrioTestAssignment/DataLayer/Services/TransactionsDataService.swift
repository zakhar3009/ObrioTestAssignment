//
//  TransactionsDataService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

protocol TransactionsOberver: AnyObject {
    func addedTransaction(_ transaction: TransactionModel)
}

protocol TransactionsService {
    func fetchTransactionsBatch(for wallet: WalletModel, offset: Int, limit: Int) -> [TransactionModel]
    func add(_ transaction: TransactionModel)
    func addObserver(_ observer: TransactionsOberver)
    func removeObserver(_ observer: TransactionsOberver)
}

class TransactionsDataService: TransactionsService {
    private let dataService: DataService
    private var observers = [TransactionsOberver]()
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func fetchTransactionsBatch(for wallet: WalletModel, offset: Int, limit: Int) -> [TransactionModel] {
        do {
            let predicate = NSPredicate(format: "wallet.walletId == %@", wallet.walletId.uuidString)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            let transactions: [Transaction] = try dataService.fetchBatch(offset: offset,
                                                                         limit: limit,
                                                                         predicate: predicate,
                                                                         sortDescriptors: [sortDescriptor])
            return transactions.compactMap { TransactionModel(from: $0) }
        } catch {
            print("Eror while fetching transactions: \(error.localizedDescription)")
        }
        return []
    }
    
    func add(_ transaction: TransactionModel) {
        let predicate = NSPredicate(format: "walletId == %@", transaction.walletId.uuidString)
        do {
            guard let wallet: Wallet = try dataService.fetchAll(predicate: predicate).first else {
                return
            }
            let model = Transaction(context: dataService.context, model: transaction)
            model.wallet = wallet
            dataService.saveChanges()
            if let transaction = TransactionModel(from: model) {
                notifyObservers(about: transaction)
            }
        } catch {
            print("Error finding wallet for transaction: \(error.localizedDescription)")
        }
    }
    
    private func notifyObservers(about transaction: TransactionModel) {
        observers.forEach { $0.addedTransaction(transaction) }
    }
    
    func addObserver(_ observer: TransactionsOberver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: TransactionsOberver) {
        observers.removeAll { $0 === observer }
    }
}
