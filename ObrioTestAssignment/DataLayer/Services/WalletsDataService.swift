//
//  WalletsDataService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

protocol WalletsObserver: AnyObject {
    func updatedBalance(for wallet: WalletModel)
}

protocol WalletsService {
    func updateBalance(with value: Decimal, for wallet: WalletModel)
    func getWallets() -> [WalletModel]
    func getWallet(by id: UUID) -> WalletModel?
    func createWallet() -> WalletModel?
    func addObserver(_ observer: WalletsObserver)
    func removeObserver(_ observer: WalletsObserver)
}

class WalletsDataService: WalletsService {
    private let dataService: DataService
    private var observers = [WalletsObserver]()
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func updateBalance(with value: Decimal, for wallet: WalletModel) {
        do {
            let predicate = NSPredicate(format: "walletId == %@", wallet.walletId.uuidString)
            if let wallet: Wallet = try dataService.fetchAll(predicate: predicate).first {
                wallet.balance = NSDecimalNumber(decimal: (wallet.balance?.decimalValue ?? 0) + value)
                dataService.saveChanges()
                if let model = WalletModel(from: wallet) {
                    notifyObservers(about: model)
                }
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
    
    func createWallet() -> WalletModel? {
        let newWallet = Wallet(context: dataService.context)
        newWallet.walletId = UUID()
        newWallet.balance = 0
        dataService.saveChanges()
        return WalletModel(from: newWallet)
    }
    
    private func notifyObservers(about wallet: WalletModel) {
        observers.forEach { $0.updatedBalance(for: wallet) }
    }
    
    func addObserver(_ observer: WalletsObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: WalletsObserver) {
        observers.removeAll { $0 === observer }
    }
}
