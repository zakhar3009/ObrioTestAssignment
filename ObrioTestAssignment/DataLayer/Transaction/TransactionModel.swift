//
//  TransactionModel.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

struct TransactionModel {
    let date: Date
    let amount: Decimal
    let category: TransactionCategories?
    let wallet: WalletModel
    let type: TransactionType
}
