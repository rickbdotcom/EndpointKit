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
        requestModifiers.map { $0.asRequestModifier().any() }
    }
}

public extension URLRequestModifier {
    
    func asRequestModifier<Parameters, Response>() -> RequestModifier<Parameters, Response> {
        RequestModifier(self)
    }
}

public extension RequestModifier {
    
    init(_ modifier: URLRequestModifier) {
        self.init { encoder, parameters, request in
            try await modifier(encoder.encode(parameters, into: request))
        }
    }
}

