//
//  StringResponseDecoder.swift
//  
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as String
public struct StringResponseDecoder: ResponseDecoder {
    public typealias Response = String

    let encoding: String.Encoding

    public init(_ encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        if let string = String(data: data, encoding: encoding) {
            return string
        } else {
            throw DecodeError.responseIsNotString
        }
    }
}

extension StringResponseDecoder {
    enum DecodeError: Error {
        case responseIsNotString
    }
}
