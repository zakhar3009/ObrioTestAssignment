//
//  TransactionModel.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

struct TransactionModel: Hashable {
    let date: Date
    let amount: Decimal
    let category: TransactionCategories?
    let walletId: UUID
    let type: TransactionType
}
