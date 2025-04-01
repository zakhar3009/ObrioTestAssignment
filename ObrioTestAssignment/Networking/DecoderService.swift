//
//  DecoderService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation

class DecoderService {
    func decode<T: Decodable>(
        from data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(T.self, from: data)
    }
}
