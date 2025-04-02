//
//  WalletModel.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

struct WalletModel {
    let walletId: UUID
    let balance: Decimal
    let transactions: [TransactionModel]
}
