//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//


import Foundation

/// An endpoint modifier that modifies an endpoint's parameters
public struct RequestModifier<Parameters, Response>: EndpointModifier {
    public typealias MapEncoder = (any RequestEncoder<Parameters>) -> any RequestEncoder<Parameters>
    public typealias Encoder = (any RequestEncoder<Parameters>, Parameters, URLRequest) async throws -> URLRequest
    let parameterEncoder: MapEncoder

    /// Create parameter modifier from an existing parameter encoder
    public init(_ parameterEncoder: @escaping MapEncoder) {
        self.parameterEncoder = parameterEncoder
    }

    public init(_ encode: @escaping Encoder) {
        self.parameterEncoder = { encoder in
            AnyRequestEncoder { parameters, request in
                try await encode(encoder, parameters, request)
            }
        }
    }

    /// Implementation of parameter modifier
    public func modify<T: Endpoint>(_ endpoint: T) -> AnyEndpoint<T.Parameters, T.Response>
    where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = endpoint.any()
        let encoder = parameterEncoder(modifiedEndpoint.requestEncoder)
        modifiedEndpoint.requestEncoder = encoder
        return modifiedEndpoint
    }
}
