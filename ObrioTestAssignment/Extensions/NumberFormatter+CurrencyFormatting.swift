//
//  NumberFormatter+Currency.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

extension NumberFormatter {
    static func formattedCurrency(value: Decimal, maximumFractionDigits: Int = 2, minimumFractionDigits: Int = 2) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        return numberFormatter.string(from: value as NSNumber)
    }
}
