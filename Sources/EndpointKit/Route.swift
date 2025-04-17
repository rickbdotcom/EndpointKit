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
