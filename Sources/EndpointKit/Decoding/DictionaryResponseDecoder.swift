//
//  DictionaryResponseDecoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Decode response as JSON deserializable Dictionary
public struct DictionaryResponseDecoder: ResponseDecoder {

    public init() { }

    public func decode<T>(from data: Data) throws -> T {
        guard let object = try JSONSerialization.jsonObject(with: data) as? T else {
            throw DecodeError.responseIsNotDictionary
        }
        return object
    }
}

public extension DictionaryResponseDecoder {
    enum DecodeError: Error {
        case responseIsNotDictionary
    }
}
