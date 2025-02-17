//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
    /// Creates a modifier that modifies the endpoint's URLRequest cachePolicy
    public static func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        RequestModifier { $0.cachePolicy(policy) }.any()
    }
}

extension RequestEncoder {
    /// Modify the URLRequest cachePolicy
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            request.cachePolicy = policy
            return request
        }
    }

}
