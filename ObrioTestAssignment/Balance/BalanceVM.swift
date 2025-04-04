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
    
    /// Updates both rate and balance views.
    func updateView() {
        updateViewRate()
        updateBalanceView()
    }
    
    /// Initializes view model with dependencies and sets up.
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
    
    /// Sets up observers and initial data.
    func setup() {
        transactionsService.addObserver(self)
        updateRate()
        updateWallet()
    }
    
    /// Updates the exchange rate view.
    func updateViewRate() {
        guard let bitcoinRate else { return }
        if let formattedRate = NumberFormatter.formattedCurrency(value: bitcoinRate) {
            delegate?.updateRateLabel("BTC = $\(formattedRate)")
        }
    }
    
    /// Updates the balance view.
    func updateBalanceView() {
        delegate?.updateBalanceLabel(wallet.balance.description)
    }
    
    /// Fetches the latest Bitcoin rate.
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
    
    /// Adds a deposit transaction.
    func addDeposit(_ value: Decimal) {
        let deposit = TransactionModel(date: Date(),
                                       amount: value,
                                       category: nil,
                                       walletId: wallet.walletId,
                                       type: .deposit)
        transactionsService.add(deposit)
    }
    
    /// Updates the wallet balance with a value.
    private func updateBalance(with value: Decimal) {
        walletsService.updateBalance(with: value, for: wallet)
        updateWallet()
    }
    
    /// Updates the wallet from the service.
    func updateWallet() {
        if let wallet = walletsService.getWallet(by: wallet.walletId)  {
            self.wallet = wallet
        } else {
            print("Could not update wallet")
        }
    }
    
    /// Validates and converts deposit string to Decimal.
    func validatedDeposit(from value: String) -> Decimal? {
        guard let amount = Decimal(string: value), amount > 0 else {
            return nil
        }
        return amount
    }
    
    /// Removes observer on deinit.
    deinit {
        transactionsService.removeObserver(self)
    }
}

extension BalanceVM: TransactionsOberver {
    /// Updates balance when a transaction is added.
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

