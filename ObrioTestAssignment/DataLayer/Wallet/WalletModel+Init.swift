//
//  WalletModel+Init.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

extension WalletModel {
    init?(from wallet: Wallet) {
        guard let id = wallet.walletId,
              let balance = wallet.balance,
              let transactions = wallet.transactions?.allObjects as? [Transaction]
        else {
            return nil
        }
        self.walletId = id
        self.balance = balance.decimalValue
        self.transactions = transactions.compactMap { TransactionModel(from: $0) }
    }
}
