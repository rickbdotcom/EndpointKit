//
//  StringResponseDecoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Decode response as String
public struct StringResponseDecoder: ResponseDecoder {
    let encoding: String.Encoding

    public init(_ encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    public func decode<T>(from data: Data) throws -> T {
        if let string = String(data: data, encoding: encoding) as? T {
            return string
        } else {
            throw DecodeError.responseIsNotString
        }
    }
}

public extension StringResponseDecoder {
    enum DecodeError: Error {
        case responseIsNotString
    }
}
