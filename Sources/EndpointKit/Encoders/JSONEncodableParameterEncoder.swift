//
//  JSONEncodableParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Encodes parameter into body as JSON (application/json)
public struct JSONEncodableParameterEncoder<T: Encodable>: RequestEncoder {
    public typealias Parameters = T

    let encoder: JSONEncoder

    public init(encoder: JSONEncoder = JSONEncoder()) {
        encoder.outputFormatting.formUnion(.sortedKeys)
        self.encoder = encoder
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(ContentType.json, forHTTPHeaderField: ContentType.header)
        modifiedRequest.httpBody = try encoder.encode(parameters)
        return modifiedRequest
    }
}

public extension JSONEncoder {

    func snakeCase() -> Self {
        set(.convertToSnakeCase)
    }

    func set(_ strategy: JSONEncoder.KeyEncodingStrategy) -> Self {
        keyEncodingStrategy = strategy
        return self
    }
}
