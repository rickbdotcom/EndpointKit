//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
    /// Creates a modifier that modifies the endpoint's URLRequest timeout
    public static func timeout(_ interval: TimeInterval) -> Self {
        RequestModifier { $0.timeout(interval) }.any()
    }
}

extension RequestEncoder {

    /// Modify the URLRequest timeout
    public func timeout(_ interval: TimeInterval) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            request.timeoutInterval = interval
            return request
        }
    }
}
