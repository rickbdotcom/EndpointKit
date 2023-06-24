//
//  Endpoint.swift
//  EndpointKit
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
    public let encoder: ParameterEncoder?
    /// How to decode the endpoint response
    /// nil can be specified to use the "default" decoder for the given response
    public let decoder: ResponseDecoder?

    /// Initializer
    public init(_ path: String, _ method: HTTPMethod, encoder: ParameterEncoder? = nil, decoder: ResponseDecoder? = nil, headers: [String: String]? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension Endpoint {

    /// Constructs URLRequest from endpoint (sans parameter encoding which is handled at the APIEndpoint level)
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
