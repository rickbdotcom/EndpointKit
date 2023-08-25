//
//  JSONEncodableParameterEncoder.swift
//  AmericanCoreNetworking
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Encodes parameter into body as JSON (application/json)
public struct JSONEncodableParameterEncoder<T: Encodable>: ParameterEncoder {
    public typealias Parameters = T
    
    let encoder: JSONEncoder

    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = try encoder.encode(parameters)
        return modifiedRequest
    }
}
