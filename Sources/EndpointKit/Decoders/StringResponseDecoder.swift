//
//  StringResponseDecoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as String
public struct StringResponseDecoder: ResponseDecoder {
    public typealias Response = String

    let encoding: String.Encoding
    let prettyifyJSON: Bool

    public init(encoding: String.Encoding = .utf8, prettyifyJSON: Bool = true) {
        self.encoding = encoding
        self.prettyifyJSON = prettyifyJSON
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        if let string = String(data: data, encoding: encoding) {
            if prettyifyJSON,
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let string = try? String(
                data: JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                encoding: .utf8
               ) {
                return string
            }
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
