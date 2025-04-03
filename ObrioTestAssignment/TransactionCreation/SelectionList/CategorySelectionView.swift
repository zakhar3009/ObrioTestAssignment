//
//  CategorySelectionItemView.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import UIKit

class CategorySelectionView: UIView {
    private var vm: CategorySelectionVM!
    private var stackView: UIStackView!
    private var categoryViews: [CategorySelectionItemView] = []
    
    func configure(with vm: CategorySelectionVM) {
        self.vm = vm
        self.vm.viewDelegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

extension CategorySelectionView: CategorySelectionDisplayDelegate {
    func updateSelectionItems() {
        categoryViews.forEach { $0.removeFromSuperview() }
        categoryViews.removeAll()
        for category in vm.categories {
            let selectionVm = CategorySelectionItemVM(
                category: category,
                isSelected: vm.selectedCategory == category,
                select: { [weak self] in
                    self?.vm.select(category: category)
                }, deselect: { [weak self] in
                    self?.vm.deselect()
                })
            let itemView = CategorySelectionItemView()
            itemView.configure(with: selectionVm)
            stackView.addArrangedSubview(itemView)
            categoryViews.append(itemView)
        }
    }
}
