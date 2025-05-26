//
//  ParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// A ParameterEncoder modifies a URLRequest by encoding the passed in parameters
public protocol RequestEncoder<Parameters>: Sendable {
    associatedtype Parameters

    func encode(_ parameters: Parameters, into request: URLRequest) async throws -> URLRequest
}

public extension URLRequest {
    func encode<T>(parameters: T, with encoder: any RequestEncoder<T>) async throws -> URLRequest {
        try await encoder.encode(parameters, into: self)
    }
}
