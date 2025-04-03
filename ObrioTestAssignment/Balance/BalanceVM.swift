//
//  BalanceVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

protocol BalanceVMDelegate: AnyObject {
    func updateRateLabel(_ rate: String)
    func updateBalanceLabel(_ balance: String)
}

class BalanceVM {
    private let walletsService: WalletsDataService
    private let rateService: BitcoinRateService
    private let transactionsService: TransactionsDataService
    
    weak var delegate: BalanceVMDelegate? {
        didSet {
            updateView()
        }
    }
    
    var bitcoinRate: Decimal? {
        didSet {
            updateViewRate()
        }
    }
    var wallet: WalletModel {
        didSet {
            updateBalanceView()
        }
    }
    
    func updateView() {
        updateViewRate()
        updateBalanceView()
    }
    
    init(wallet: WalletModel,
         walletsService: WalletsDataService,
         rateService: BitcoinRateService,
         transactionsService: TransactionsDataService
    ) {
        self.wallet = wallet
        self.walletsService = walletsService
        self.rateService = rateService
        self.transactionsService = transactionsService
        setup()
    }
    
    func setup() {
        transactionsService.addObserver(self)
        updateRate()
        updateWallet()
    }
    
    func updateViewRate() {
        guard let bitcoinRate else { return }
        if let formattedRate = NumberFormatter.formattedCurrency(value: bitcoinRate) {
            delegate?.updateRateLabel("BTC = $\(formattedRate)")
        }
    }
    
    func updateBalanceView() {
        delegate?.updateBalanceLabel(wallet.balance.description)
    }
    
    func updateRate() {
        Task {
            guard let currencyRate = await rateService.fetchRate() else {
                return
            }
            await MainActor.run {
                self.bitcoinRate = currencyRate.rate
            }
        }
    }
    
    func addDeposit(_ value: Decimal) {
        let deposit = TransactionModel(date: Date(),
                                       amount: value,
                                       category: nil,
                                       walletId: wallet.walletId,
                                       type: .deposit)
        transactionsService.add(deposit)
    }
    
    private func updateBalance(with value: Decimal) {
        walletsService.updateBalance(with: value, for: wallet)
        updateWallet()
    }
    
    func updateWallet() {
        if let wallet = walletsService.getWallet(by: wallet.walletId)  {
            self.wallet = wallet
        } else {
            print("Could not update wallet")
        }
    }
    
    deinit {
        transactionsService.removeObserver(self)
    }
}

extension BalanceVM: TransactionsOberver {
    func addedTransaction(_ transaction: TransactionModel) {
        guard wallet.walletId == transaction.walletId else { return }
        switch transaction.type {
        case .deposit:
            updateBalance(with: transaction.amount)
        case .expense:
            updateBalance(with: -transaction.amount)
        }
    }
}

