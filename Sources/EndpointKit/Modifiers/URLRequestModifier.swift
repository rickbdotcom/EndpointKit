//
//  URLRequestModifier.swift
//  backoff
//
//  Created by Richard Burgess on 1/2/26.
//

import Foundation

public protocol URLRequestModifier: Sendable {
    func callAsFunction(_ urlRequest: URLRequest) async throws -> URLRequest
}

public struct AnyURLRequestModifier: URLRequestModifier {
    let modify: @Sendable (URLRequest) async throws -> URLRequest

    public init(_ modify: @Sendable @escaping (URLRequest) async throws -> URLRequest) {
        self.modify = modify
    }
    
    public func callAsFunction(_ urlRequest: URLRequest) async throws -> URLRequest {
        try await modify(urlRequest)
    }
}

public struct URLRequestModifiers: EndpointModifiers {
    let requestModifiers: [URLRequestModifier]
    
    public init(_ requestModifiers: [URLRequestModifier]) {
        self.requestModifiers = requestModifiers
    }
    
    public func modifiers<T: Endpoint>(for endpoint: T) -> [AnyEndpointModifier<T.Parameters, T.Response>] {
        requestModifiers.map { .modifyRequest($0) }
    }
}

extension AnyEndpointModifier {
    public static func modifyRequest(_ modify: URLRequestModifier) -> Self {
        RequestModifier {
            $0.modifyRequest(modify)
        }.any()
    }
}

extension RequestEncoder {
    public func modifyRequest(_ modify: URLRequestModifier) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            return try await encode(parameters, into: modify(request))
        }
    }
}
