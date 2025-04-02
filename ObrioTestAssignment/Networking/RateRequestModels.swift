//
//  RateRequestModels.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

struct CryptoResponse: Codable {
    let data: CryptoData
    let timestamp: TimeInterval
}

struct CryptoData: Codable {
    let id: String
    let rank: String
    let symbol: String
    let name: String
    let priceUsd: String
    let changePercent24Hr: String
}
