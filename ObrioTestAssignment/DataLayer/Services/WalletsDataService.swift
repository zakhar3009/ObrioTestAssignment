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
            let predicate = NSPredicate(format: "walletId == %@", wallet.walletId.uuidString)
            if let wallet: Wallet = try dataService.fetchAll(predicate: predicate).first {
                wallet.balance = NSDecimalNumber(decimal: (wallet.balance?.decimalValue ?? 0) + value)
                dataService.saveChanges()
            } else {
                fatalError("Wallet not found")
            }
        } catch {
            print("Eror while fetching wallet: \(error.localizedDescription)")
        }
    }
    
    func getWallets() -> [WalletModel] {
        do {
            let wallets: [Wallet] = try dataService.fetchAll()
            return wallets.compactMap { WalletModel(from: $0) }
        } catch {
            print("Error fetching wallets: \(error.localizedDescription)")
            return []
        }
    }
    
    func getWallet(by id: UUID) -> WalletModel? {
        do {
            if let wallet: Wallet = try dataService.fetchAll().first {
                return WalletModel(from: wallet)
            }
        } catch {
            print("Error fetching wallet: \(error.localizedDescription)")
        }
        return nil
    }
    
    func createMainWallet() -> WalletModel? {
        let newWallet = Wallet(context: dataService.context)
        newWallet.walletId = UUID()
        newWallet.balance = 0
        dataService.saveChanges()
        return WalletModel(from: newWallet)
    }
}
