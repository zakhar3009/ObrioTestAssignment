//
//  CategorySelectionVM.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import Foundation

protocol CategorySelectionDisplayDelegate: AnyObject {
    func updateSelectionItems()
}

protocol CategorySelectionUpdateDelegate: AnyObject {
    func categoryUpdated()
}

class CategorySelectionVM {
    let categories = TransactionCategories.allCases
    private(set) var selectedCategory: TransactionCategories?
    weak var selectionDelegate: CategorySelectionUpdateDelegate?
    weak var viewDelegate: CategorySelectionDisplayDelegate? {
        didSet {
            viewDelegate?.updateSelectionItems()
        }
    }
    
    /// Selects a category and updates the view and selection delegates.
    func select(category: TransactionCategories) {
        selectedCategory = category
        viewDelegate?.updateSelectionItems()
        selectionDelegate?.categoryUpdated()
    }
    
    /// Deselects the current category and updates the view and selection delegates.
    func deselect() {
        selectedCategory = nil
        viewDelegate?.updateSelectionItems()
        selectionDelegate?.categoryUpdated()
    }
}
