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
    let requestEncoder: MapEncoder

    /// Create parameter modifier from an existing parameter encoder
    public init(_ RequestEncoder: @escaping MapEncoder) {
        self.requestEncoder = RequestEncoder
    }

    /// Implementation of parameter modifier
    public func modify<T: Endpoint>(_ endpoint: T) -> AnyEndpoint<T.Parameters, T.Response>
    where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = endpoint.any()
        let encoder = requestEncoder(modifiedEndpoint.requestEncoder)
        modifiedEndpoint.requestEncoder = encoder
        return modifiedEndpoint
    }
}
