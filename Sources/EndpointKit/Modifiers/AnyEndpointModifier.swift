//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

/// Type erased endpoint modifier
public struct AnyEndpointModifier<Parameters, Response>: EndpointModifier {
    let _modify: (AnyEndpoint<Parameters, Response>) -> AnyEndpoint<Parameters, Response>

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

extension AnyEndpointModifier {
    /// Create a modifier that modifies the endpoint's Content-Type
    public static func contentType(_ contentType: String) -> Self {
        RequestModifier { $0.contentType(contentType) }.any()
    }

    /// Create a modifier that merges the endpoint's headers
    public static func merge(
        headers: [String : String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { a, _ in a }
    ) -> Self {
        RequestModifier { $0.merge(headers: headers, uniquingKeysWith: combine) }.any()
    }

    /// Create a modifier that removes the endpoint's headers
    public static func remove(headers: [String]) -> Self {
        RequestModifier { $0.remove(headers: headers) }.any()
    }

    /// Create a modifier that verifies the response is a non-error HTTP code
    public static func validateHTTP() -> Self {
        ResponseModifier { $0.validateHTTP() }.any()
    }

    /// Creates a modifier that modifies the endpoint's URLRequest cachePolicy
    public static func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        RequestModifier { $0.cachePolicy(policy) }.any()
    }

    /// Creates a modifier that modifies the endpoint's URLRequest timeout
    public static func timeout(_ interval: TimeInterval) -> Self {
        RequestModifier { $0.timeout(interval) }.any()
    }
}
