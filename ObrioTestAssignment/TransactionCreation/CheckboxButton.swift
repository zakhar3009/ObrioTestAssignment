//
//  CheckboxButton.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import UIKit

class CheckboxButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        frame.size = CGSize(width: 44, height: 44)
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .clear
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .systemBlue : .clear
        }
    }
}
