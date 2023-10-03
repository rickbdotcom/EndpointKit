//
//  Endpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

/// Encapsulates all the information needed to make an HTTP request to a particular endpoint
public struct Endpoint {
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

extension Endpoint: ExpressibleByStringLiteral {

    public init(stringLiteral: StringLiteralType) {
        let comps = stringLiteral.components(separatedBy: " ")
        guard comps.count == 2,
              let method = HTTPMethod(rawValue: comps[0]) else {
            preconditionFailure("Invalid Endpoint string: \(stringLiteral)")
        }

        self.path = comps[1]
        self.method = method
    }
}

extension URLRequest {

    init(baseURL: URL, endpoint: Endpoint) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        self = request
    }
}
