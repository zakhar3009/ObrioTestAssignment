//
//  ViewController.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import UIKit

class WalletController: UIViewController {
    private var vm: WalletVM!
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Content>!
    static let sectionHeaderKind = "sectionHeaderKind"
    
    enum Section: Hashable {
        case wallet
        case transactionsGroup(Date)
    }
    
    enum Content: Hashable {
        case balance
        case transaction(TransactionModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupCollectionView()
        let dataService = DataService()
        self.vm = WalletVM(walletService: WalletsDataService(dataService: dataService),
                           rateService: BitcoinRateService(networkService: NetworkingService(decoderService: DecoderService()),
                                                           dataService: dataService),
                             transactionsService: TransactionsDataService(dataService: dataService))
        vm.delegate = self
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(BalanceCell.self, forCellWithReuseIdentifier: BalanceCell.reuseIdentifier)
        collectionView.register(TransactionCell.self, forCellWithReuseIdentifier: TransactionCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: Self.sectionHeaderKind,
                                withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        self.view.addSubview(collectionView)
        self.dataSource = makeDateSource()
        updateBalanceCell()
    }
    
    func updateBalanceCell() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.wallet])
        snapshot.appendItems([.balance], toSection: .wallet)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createCompositionLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.dataSource.sectionIdentifier(for: sectionIndex)!
            return self.createSectionLayout(section: section)
        }
        return layout
    }
    
    func createSectionLayout(section: Section) -> NSCollectionLayoutSection {
        switch section {
        case .wallet:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25)), subitems: [item])
            return NSCollectionLayoutSection(group: group)
        case .transactionsGroup(let date):
            let itemsCount = vm.transactions(for: date).count
            return createTransactionsSection(with: itemsCount)
        }
    }
    
    func createTransactionsSection(with itemsCount: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50 * Double(itemsCount)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: Self.sectionHeaderKind,
            alignment: .top
        )
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
        return section
    }
}

extension WalletController {
    private func createBalanceCellRegistration() -> UICollectionView.CellRegistration<BalanceCell, Void> {
        UICollectionView.CellRegistration<BalanceCell, Void> { [weak self] (cell, indexPath, _) in
            guard let self else { return }
            let vm = BalanceVM(wallet: self.vm.mainWallet,
                               walletsService: self.vm.walletService,
                               rateService: self.vm.rateService,
                               transactionsService: self.vm.transactionsService)
            cell.configure(vm: vm, delegate: self)
        }
    }
    
    private func createTransactionsCellRegistration() -> UICollectionView.CellRegistration<TransactionCell, TransactionModel> {
        UICollectionView.CellRegistration<TransactionCell, TransactionModel> { (cell, _, transaction) in
            cell.configure(vm: TransactionCellVM(transaction: transaction))
        }
    }
    
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SectionHeaderView> {
        UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: WalletController.sectionHeaderKind
        ) { [weak self] supplementaryView, _, indexPath in
            guard let self else { return }
            let section = self.dataSource.sectionIdentifier(for: indexPath.section)!
            if case .transactionsGroup(let date) = section {
                supplementaryView.configure(text: date.format(to: "dd MMM"))
            }
        }
    }
}

extension WalletController {
    private func makeDateSource() -> UICollectionViewDiffableDataSource<Section, Content> {
        let balanceRegistration = createBalanceCellRegistration()
        let transactionRegistration = createTransactionsCellRegistration()
        let headerRegistration = createHeaderRegistration()
        let dataSource: UICollectionViewDiffableDataSource<Section, Content> = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) in
                switch item {
                case .balance:
                    return collectionView.dequeueConfiguredReusableCell(using: balanceRegistration, for: indexPath, item: ())
                case .transaction(let transaction):
                    return collectionView.dequeueConfiguredReusableCell(using: transactionRegistration, for: indexPath, item: transaction)
                }
            })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return dataSource
    }
}
extension WalletController: BalanceCellDelegate {
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
