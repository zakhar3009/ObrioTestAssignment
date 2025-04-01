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
              let categoryName = transaction.category,
              let category = TransactionCategories(rawValue: categoryName)
        else {
            return nil
        }
        self.date = date
        self.amount = amount.decimalValue
        self.category = category
    }
}
