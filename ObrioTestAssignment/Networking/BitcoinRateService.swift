//
//  BitcoinRateService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 02.04.2025.
//

import Foundation

protocol RateService {
    func fetchRate() async -> CurrencyRateModel?
}

class BitcoinRateService: RateService {
    private let networkService: NetworkingService
    private let dataService: DataService
    private let bitcoinRateUrl = URL(string: "https://api.coincap.io/v2/assets/bitcoin")!
    
    init(networkService: NetworkingService, dataService: DataService) {
        self.networkService = networkService
        self.dataService = dataService
    }
    
    /// Fetches the current Bitcoin rate, either from the database or network.
    func fetchRate() async -> CurrencyRateModel? {
        if let dbRate = fetchFromDb(), checkDataRelevance(model: dbRate) {
            return dbRate // Return cached rate if it's still relevant
        } else if let networkRate = await fetchFromNetwork() {
            save(networkRate) // Save new rate to the database
            return networkRate
        }
        return nil
    }
    
    /// Fetches the Bitcoin rate from the network API.
    private func fetchFromNetwork() async -> CurrencyRateModel? {
        do {
            let response: CryptoResponse = try await networkService.fetch(from: bitcoinRateUrl)
            let data = response.data
            if let rate = Decimal(string: data.priceUsd) {
                return CurrencyRateModel(lastUpdate: Date(), rate: rate)
            }
        } catch {
            if let networkError = error as? NetworkingError {
                print("Network error while fetching rate: \(networkError.description)")
            } else {
                print("Unknown error while fetching rate: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /// Fetches the Bitcoin rate from the local database.
    private func fetchFromDb() -> CurrencyRateModel? {
        do {
            let sortDescriptor = NSSortDescriptor(key: "lastUpdate", ascending: false)
            let rate: CurrencyRate? = try dataService.fetchBatch(offset: 0, limit: 1, sortDescriptors: [sortDescriptor]).first
            if let rate {
                return CurrencyRateModel(from: rate)
            }
        } catch {
            print("Erorr fetching rate from db: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// Saves the Bitcoin rate model to the database.
    private func save(_ model: CurrencyRateModel) {
        let _ = CurrencyRate(context: dataService.context, model: model)
        dataService.saveChanges()
    }
    
    /// Checks if the stored rate data is still relevant (within the last hour).
    private func checkDataRelevance(model: CurrencyRateModel) -> Bool {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(model.lastUpdate)
        return timeInterval < 60 * 60
    }
}
