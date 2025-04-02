//
//  BitcoinRateService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

class BitcoinRateService {
    private let networkService: NetworkingService
    private let bitcoinRateUrl = URL(string: "https://api.coincap.io/v2/assets/bitcoin")!
    
    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
    
    func fetchRate() async throws -> CryptoData {
        let response: CryptoResponse = try await networkService.fetch(from: bitcoinRateUrl)
        return response.data
    }
}
