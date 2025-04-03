//
//  TransactionCellVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

class TransactionCellVM {
    let transaction: TransactionModel
    
    init(transaction: TransactionModel) {
        self.transaction = transaction
    }
    
    var formattedDate: String {
        transaction.date.format(to: "hh:mm a")
    }
    
    var category: String {
        transaction.category?.rawValue ?? "Deposit"
    }
    
    var amount: String {
        NumberFormatter.formattedCurrency(value: transaction.amount) ?? ""
    }
}
