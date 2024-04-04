//
//  DictionaryResponseDecoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as JSON deserializable Dictionary
public struct SerializedJSONResponseDecoder<T>: ResponseDecoder {
    public typealias Response = T

    public init() { }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        guard let object = try JSONSerialization.jsonObject(with: data) as? Response else {
            throw DecodeError.dataResponseDoesntMatch
        }
        return object
    }

    enum DecodeError: Error {
        case dataResponseDoesntMatch
    }
}
