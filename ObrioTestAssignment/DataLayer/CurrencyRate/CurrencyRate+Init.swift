//
//  CurrencyRate+Init.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

extension CurrencyRateModel {
    init?(from currencyRate: CurrencyRate) {
        guard let date = currencyRate.lastUpdate,
              let rate = currencyRate.rate
        else {
            return nil
        }
        self.lastUpdate = date
        self.rate = rate.decimalValue
    }
}
