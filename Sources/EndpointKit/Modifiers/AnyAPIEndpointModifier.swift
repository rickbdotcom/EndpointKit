//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

/// Type erased endpoint modifier
public struct AnyAPIEndpointModifier<Parameters, Response>: APIEndpointModifier {
    let _modify: (AnyAPIEndpoint<Parameters, Response>) -> AnyAPIEndpoint<Parameters, Response>

    /// Create type erased modifier from existing modifier
    public init(_ modifier: any APIEndpointModifier<Parameters, Response>) {
        _modify = { endpoint in
            modifier.modify(endpoint)
        }
    }

    /// Implementation of type erased modifier
    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<Parameters, Response> 
    where T.Parameters == Parameters, T.Response == Response {
        _modify(apiEndpoint.any())
    }
}

extension APIEndpointModifier {

    /// Create type erased modifier
    public func any() -> AnyAPIEndpointModifier<Parameters, Response> {
        AnyAPIEndpointModifier(self)
    }
}

extension AnyAPIEndpointModifier {
    /// Create a modifier that modifies the endpoint's Content-Type
    public static func contentType(_ contentType: String) -> Self {
        APIEndpointParameterModifier { $0.contentType(contentType) }.any()
    }

    /// Create a modifier that merges the endpoint's headers
    public static func merge(
        headers: [String : String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { a, _ in a }
    ) -> Self {
        APIEndpointParameterModifier { $0.merge(headers: headers, uniquingKeysWith: combine) }.any()
    }

    /// Create a modifier that removes the endpoint's headers
    public static func remove(headers: [String]) -> Self {
        APIEndpointParameterModifier { $0.remove(headers: headers) }.any()
    }

    /// Create a modifier that verifies the response is a non-error HTTP code
    public static func validateHTTP() -> Self {
        APIEndpointResponseModifier { $0.validateHTTP() }.any()
    }
}
