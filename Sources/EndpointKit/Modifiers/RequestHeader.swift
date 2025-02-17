//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
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
}

extension RequestEncoder {
    /// Modify parameter encoder to merge the headers
    public func merge(
        headers: [String: String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { a, _ in a }
    ) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            let requestHeaders = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = headers.merging(requestHeaders, uniquingKeysWith: combine)
            return request
        }
    }

    /// Modify parameter encoder to remove headers
    public func remove(headers: [String]) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            if let requestHeaders = request.allHTTPHeaderFields {
                request.allHTTPHeaderFields = requestHeaders.filter { key, _ in
                    headers.contains(key) == false
                }
            }
            return request
        }
    }
}
