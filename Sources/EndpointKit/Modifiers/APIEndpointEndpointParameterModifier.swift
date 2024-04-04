//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//


import Foundation

/// An endpoint modifier that modifies an endpoint's parameters
public struct APIEndpointParameterModifier<Parameters, Response>: APIEndpointModifier {
    public typealias MapEncoder = (any ParameterEncoder<Parameters>) -> any ParameterEncoder<Parameters>
    let parameterEncoder: MapEncoder

    /// Create parameter modifier from an existing parameter encoder
    public init(_ parameterEncoder: @escaping MapEncoder) {
        self.parameterEncoder = parameterEncoder
    }

    /// Create parameter modifier from function
    public init(_ encode: @escaping (any ParameterEncoder<Parameters>, Parameters, URLRequest) async throws -> URLRequest) {
        parameterEncoder = { encoder in
            AnyParameterEncoder { parameters, request in
                try await encode(encoder, parameters, request)
            }
        }
    }

    /// Implementation of parameter modifier
    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response>
    where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = apiEndpoint.any()
        let encoder = parameterEncoder(modifiedEndpoint.parameterEncoder)
        modifiedEndpoint.parameterEncoder = encoder
        return modifiedEndpoint
    }
}
