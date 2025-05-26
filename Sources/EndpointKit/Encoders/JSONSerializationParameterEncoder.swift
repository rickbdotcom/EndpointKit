//
//  SerializedJSONParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Endpoint parameters are specified as a JSON Encodable Dictionary (application/json)
public struct JSONSerializationParameterEncoder<T>: RequestEncoder {
    public typealias Parameters = T

    let options: JSONSerialization.WritingOptions

    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options.union(.sortedKeys)
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw EncodeError.invalidJSON
        }
        var modifiedRequest = request
        modifiedRequest.setValue(ContentType.json, forHTTPHeaderField: ContentType.header)
        modifiedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: options)
        return modifiedRequest
    }

    enum EncodeError: Error {
        case invalidJSON
    }
}
