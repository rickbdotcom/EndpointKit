//
//  JSONDecodableResponseDecoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as JSON Decodable
public struct JSONDecodableResponseDecoder<T: Decodable>: ResponseDecoder {
    public typealias Response = T

    let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONDecodingError(
                response: response,
                data: data,
                decodingError: error
            )
        }
    }
}

public extension JSONDecoder {

    func snakeCase() -> Self {
        set(.convertFromSnakeCase)
    }

    func set(_ strategy: JSONDecoder.KeyDecodingStrategy) -> Self {
        keyDecodingStrategy = strategy
        return self
    }
}

public struct JSONDecodingError: Error {
    let response: URLResponse
    let data: Data
    let decodingError: Error
}
