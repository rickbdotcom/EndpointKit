//
//  Endpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

public struct Route: Equatable, Sendable {
    /// The HTTP Method
    public let method: HTTPMethod
    /// The relative path to the endpoint
    public let path: String

    /// Initializer
    public init(_ method: HTTPMethod, _ path: String) {
        self.method = method
        self.path = path
    }
}

public func POST(_ path: String) -> Route {
    .init(.post, path)
}

public func GET(_ path: String) -> Route {
    .init(.get, path)
}

public func PUT(_ path: String) -> Route {
    .init(.put, path)
}

public func DELETE(_ path: String) -> Route {
    .init(.delete, path)
}

public func HEAD(_ path: String) -> Route {
    .init(.head, path)
}

public extension URLRequest {
    init(
        baseURL: URL,
        endpoint: Route,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0
    ) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.method.rawValue
        self = request
    }
}
