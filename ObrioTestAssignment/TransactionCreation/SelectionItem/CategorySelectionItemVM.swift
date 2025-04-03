//
//  CategorySelectionItemVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import Foundation

class CategorySelectionItemVM {
    let category: TransactionCategories
    private(set) var isSelected = false
    private let select: () -> Void
    private let deselect: () -> Void
    
    init(category: TransactionCategories, isSelected: Bool, select: @escaping () -> Void, deselect: @escaping () -> Void) {
        self.category = category
        self.isSelected = isSelected
        self.select = select
        self.deselect = deselect
    }
    
    @objc
    func toggleSelection() {
        if isSelected {
            deselect()
        } else {
            select()
        }
    }
}
