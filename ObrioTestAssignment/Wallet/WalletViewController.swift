//
//  ViewController.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import UIKit

class WalletViewController: UIViewController {
    weak var coordinator: WalletCoordinator?
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
    }
    
    func configure(with vm: WalletVM) {
        self.vm = vm
        setupCollectionView()
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
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        self.dataSource = makeDateSource()
    }
}

extension WalletViewController {
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

extension WalletViewController {
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
        UICollectionView.CellRegistration<TransactionCell, TransactionModel> { [weak self] (cell, indexPath, transaction) in
            guard let self else { return }
            cell.configure(vm: TransactionCellVM(transaction: transaction))
        }
    }
    
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SectionHeaderView> {
        UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: Self.sectionHeaderKind
        ) { [weak self] supplementaryView, _, indexPath in
            guard let self else { return }
            let section = self.dataSource.sectionIdentifier(for: indexPath.section)!
            if case .transactionsGroup(let date) = section {
                supplementaryView.configure(text: date.format(to: "dd MMM"))
            }
        }
    }
}

extension WalletViewController {
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

extension WalletViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         -1 because transactions starts from second section
//         should be changed
        guard indexPath.section > 0 else { return }
        let allLoadedCellsCount = self.vm.transactions.prefix(indexPath.section - 1)
            .flatMap(\.transactions)
            .count + indexPath.row + 1
        if allLoadedCellsCount == vm.allTransactionsCount {
            print("Fetch new batch")
            vm.fetchNewTransactions()
        }
    }
}

extension WalletViewController: TransactionsViewDelegate {
    func updateTransactions() {
        var snaphot = NSDiffableDataSourceSnapshot<Section, Content>()
        snaphot.appendSections([.wallet])
        snaphot.appendItems([.balance], toSection: .wallet)
        if !vm.transactions.isEmpty {
            vm.transactions.forEach { (date, transactions) in
                let section = Section.transactionsGroup(date)
                let items = transactions.map { Content.transaction($0) }
                snaphot.appendSections([section])
                snaphot.appendItems(items, toSection: section)
            }
        }
        dataSource.apply(snaphot, animatingDifferences: true)
    }
}

extension WalletViewController: BalanceCellDelegate {
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    func goToCreation() {
        coordinator?.goToTransactionCreation(for: vm.mainWallet)
    }
}
