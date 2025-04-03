//
//  TransactionModel+Init.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

extension TransactionModel {
    init?(from transaction: Transaction) {
        guard let date = transaction.date,
              let amount = transaction.amount,
              let walletId = transaction.wallet?.walletId,
              let type = transaction.type,
              let transactionType = TransactionType(rawValue: type)
        else {
            return nil
        }
        self.date = date
        self.amount = amount.decimalValue
        self.walletId = walletId
        self.type = transactionType
        if let categoryName = transaction.category,
           let category = TransactionCategories(rawValue: categoryName) {
            self.category = category
        } else {
            self.category = nil
        }
    }
}
