//
//  DictionaryResponseDecoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as JSON deserializable Dictionary
public struct JSONSerializationResponseDecoder<T>: ResponseDecoder {
    public typealias Response = T

    let options: JSONSerialization.ReadingOptions

    public init(options: JSONSerialization.ReadingOptions = []) {
        self.options = options
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        guard let object = try JSONSerialization.jsonObject(with: data, options: options) as? Response else {
            throw DecodeError.dataResponseDoesntMatch
        }
        return object
    }

    enum DecodeError: Error {
        case dataResponseDoesntMatch
    }
}
