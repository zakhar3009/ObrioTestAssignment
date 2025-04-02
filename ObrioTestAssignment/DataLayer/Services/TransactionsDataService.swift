//
//  TransactionsDataService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

class TransactionsDataService {
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func fetchTransactionsBatch(offset: Int, limit: Int) -> [TransactionModel] {
        do {
            let transactions: [Transaction] = try dataService.fetchBatch(offset: offset, limit: limit)
            return transactions.compactMap { TransactionModel(from: $0) }
        } catch {
            print("Eror while fetching transactions: \(error.localizedDescription)")
        }
        return []
    }
    
    func create(_ transaction: TransactionModel) {
        let _ = Transaction(context: dataService.context, model: transaction)
        dataService.saveChanges()
    }
}
