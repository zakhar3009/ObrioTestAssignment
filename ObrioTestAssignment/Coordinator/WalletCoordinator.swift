//
//  TransactionsCoordinator.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import UIKit

class WalletCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    private let dataService = DataService()
    private let decoderService = DecoderService()
    private lazy var networkService: NetworkingService = {
        NetworkingService(decoderService: decoderService)
    }()
    private lazy var walletService: WalletsDataService = {
        WalletsDataService(dataService: dataService)
    }()
    private lazy var transactionsService: TransactionsDataService = {
        TransactionsDataService(dataService: dataService)
    }()
    private lazy var rateService: BitcoinRateService = {
        BitcoinRateService(networkService: networkService, dataService: dataService)
    }()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let walletVC = WalletViewController()
        walletVC.coordinator = self
        let walletVM = WalletVM(walletService: walletService,
                                rateService: rateService,
                                transactionsService: transactionsService)
        walletVC.configure(with: walletVM)
        navigationController.pushViewController(walletVC, animated: true)
    }
    
    func goToTransactionCreation(for wallet: WalletModel) {
        let creationVC = TransactionCreationViewController()
        let creationVM = TransactionCreationVM(transactionService: transactionsService, wallet: wallet)
        creationVC.coordinator = self
        creationVC.configure(with: creationVM)
        navigationController.pushViewController(creationVC, animated: true)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
