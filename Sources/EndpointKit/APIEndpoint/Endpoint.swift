//
//  Endpoint.swift
//  AmericanCoreNetworking
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

/// Encapsulates all the information needed to make an HTTP request to a particular endpoint
public struct Endpoint {
    /// The relative path to the endpoint
    public let path: String
    /// The HTTP Method
    public let method: HTTPMethod
    /// Any headers required that aren't supplied though other means
    public let headers: [String: String]?
    /// How to encode the parameters passed to the endpoint
    /// nil can be specified to use the "default" encoder for the given parameter and method

    /// Initializer
    public init(_ path: String, _ method: HTTPMethod, headers: [String: String]? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
    }
}

extension Endpoint {

    /// Constructs URLRequest from endpoint
    func request(baseURL: URL) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
