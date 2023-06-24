//
//  APIEndpoint+Request.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Default implement for Void parameters
public extension APIEndpoint where Parameters == Void {
    var parameters: () { () }

    func request(baseURL: URL) throws -> URLRequest {
        try endpoint.request(baseURL: baseURL)
    }
}

/// Default implement for Encodable parameters
public extension APIEndpoint where Parameters: Encodable {

    func request(baseURL: URL) throws -> URLRequest {
        var request = try endpoint.request(baseURL: baseURL)
        try request.encode(parameters, with: endpoint.encoder ?? defaultEncoder())
        return request
    }

    func defaultEncoder() -> ParameterEncoder {
        if endpoint.method == .get {
            return URLParameterEncoder()
        } else {
            return JSONEncoder().parameterEncoder
        }
    }
}

/// Default implement for Data parameters
public extension APIEndpoint where Parameters == Data {

    func request(baseURL: URL) throws -> URLRequest {
        var request = try endpoint.request(baseURL: baseURL)
        try request.encode(parameters, with: endpoint.encoder ?? DataParameterEncoder())
        return request
    }
}

/// Default implement for Dictionary parameters
public extension APIEndpoint where Parameters == [String: Any] {

    func request(baseURL: URL) throws -> URLRequest {
        var request = try endpoint.request(baseURL: baseURL)
        try request.encode(parameters, with: endpoint.encoder ?? DictionaryParameterEncoder())
        return request
    }
}
