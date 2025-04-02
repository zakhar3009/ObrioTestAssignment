//
//  NetworkingService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

enum NetworkingError: Error {
    case requestError
    case decodingError
    case invalidResponse
    
    var description: String {
        switch self {
        case .requestError:
            "Network request error"
        case .decodingError:
            "Decoding error"
        case .invalidResponse:
            "Invalid response"
        }
    }
}

class NetworkingService {
    let decoderService: DecoderService
    
    init(decoderService: DecoderService) {
        self.decoderService = decoderService
    }
    
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw NetworkingError.requestError
        }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NetworkingError.invalidResponse
        }
        guard let decodedData: T = try? decoderService.decode(from: data) else {
            throw NetworkingError.decodingError
        }
        return decodedData
    }
}
