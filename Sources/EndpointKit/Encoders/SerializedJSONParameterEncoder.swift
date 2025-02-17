//
//  SerializedJSONParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Endpoint parameters are specified as a JSON Encodable Dictionary (application/json)
public struct SerializedJSONParameterEncoder<T>: RequestEncoder {
    public typealias Parameters = T

    public init() {
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(ContentType.json, forHTTPHeaderField: ContentType.header)
        modifiedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        return modifiedRequest
    }
}
