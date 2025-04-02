//
//  WalletsDataService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

class WalletsDataService {
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func updateBalance(with value: Decimal, for wallet: WalletModel) {
        do {
            if let wallet: Wallet = try dataService.find(by: wallet.walletId, idField: "walletId") {
                wallet.balance = NSDecimalNumber(decimal: (wallet.balance?.decimalValue ?? 0) + value)
                dataService.saveChanges()
            } else {
                fatalError("Wallet not found")
            }
        } catch {
            print("Eror while fetching wallet: \(error.localizedDescription)")
        }
    }
    
    func getMainWallet() -> WalletModel? {
        do {
            if let wallet: Wallet = try dataService.fetchAll().first {
                return WalletModel(from: wallet)
            }
        } catch {
            print("Error fetching wallet: \(error.localizedDescription)")
        }
        return nil
    }
    
    func createMainWallet() {
        let newWallet = Wallet(context: dataService.context)
        newWallet.walletId = UUID()
        newWallet.balance = 0
        dataService.saveChanges()
    }
}
