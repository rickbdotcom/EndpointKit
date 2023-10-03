//
//  Endpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

/// Encapsulates all the information needed to make an HTTP request to a particular endpoint
public struct Endpoint: Equatable {
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
