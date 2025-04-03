//
//  CategorySelection.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import UIKit

class CategorySelectionItemView: UIView {
    private var vm: CategorySelectionItemVM!
    private var stackView: UIStackView!
    private var titleLabel: UILabel!
    private var checkboxButton: CheckboxButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with vm: CategorySelectionItemVM) {
        self.vm = vm
        checkboxButton.addTarget(self.vm, action: #selector(self.vm.toggleSelection), for: .touchUpInside)
        titleLabel.text = vm.category.rawValue
        checkboxButton.isSelected = vm.isSelected
    }
    
    private func setupUI() {
        setupStackView()
        setupCheckbox()
        setupCategoryLabel()
    }
    
    private func setupCheckbox() {
        checkboxButton = CheckboxButton()
        stackView.addArrangedSubview(checkboxButton)
    }
    
    private func setupCategoryLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        NSLayoutConstraint.activate([
            checkboxButton.widthAnchor.constraint(equalToConstant: 20),
            checkboxButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
