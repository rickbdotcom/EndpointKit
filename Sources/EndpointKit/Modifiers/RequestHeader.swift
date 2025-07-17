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
        uniquingKeysWith combine: @escaping (String, String) -> String = { $1 }
    ) -> Self {
        RequestModifier {
            $0.merge(headers: headers, uniquingKeysWith: combine)
        }.any()
    }

    /// Create a modifier that removes the endpoint's headers
    public static func remove(headers: [String]) -> Self {
        RequestModifier {
            $0.remove(headers: headers)
        }.any()
    }
}

extension RequestEncoder {
    /// Modify parameter encoder to merge the headers
    public func merge(
        headers: [String: String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { $1 }
    ) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            try await encode(parameters, into: request).merge(
                headers: headers,
                uniquingKeysWith: combine
            )
        }
    }

    /// Modify parameter encoder to remove headers
    public func remove(headers: [String]) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            try await encode(parameters, into: request).remove(headers: headers)
        }
    }
}

extension URLRequest {
    public func merge(
        headers: [String: String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { $1 }
    ) -> URLRequest {
        var request = self
        headers.forEach {
            if let header = request.value(forHTTPHeaderField: $0.key) {
                request.setValue(combine(header, $0.value), forHTTPHeaderField: $0.key)
            } else {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        return request
    }

    public func remove(headers: [String]) -> URLRequest {
        var request = self
        headers.forEach {
            request.setValue(nil, forHTTPHeaderField: $0)
        }
        return request
    }
}
