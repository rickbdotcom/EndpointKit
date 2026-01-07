//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

/// Type erased endpoint modifier
public struct AnyEndpointModifier<Parameters: Sendable, Response: Sendable>: EndpointModifier {
    let _modify: @Sendable (AnyEndpoint<Parameters, Response>) -> AnyEndpoint<Parameters, Response>

    /// Create type erased modifier from existing modifier
    public init(_ modifier: any EndpointModifier<Parameters, Response>) {
        _modify = { endpoint in
            modifier.modify(endpoint)
        }
    }

    /// Implementation of type erased modifier
    public func modify<T: Endpoint>(_ endpoint: T) -> AnyEndpoint<Parameters, Response> 
    where T.Parameters == Parameters, T.Response == Response {
        _modify(endpoint.any())
    }
}

extension EndpointModifier {

    /// Create type erased modifier
    public func any() -> AnyEndpointModifier<Parameters, Response> {
        AnyEndpointModifier(self)
    }
}
