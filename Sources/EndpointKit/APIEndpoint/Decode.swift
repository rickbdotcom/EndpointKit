//
//  APIEndpoint+Decode.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Default implement for Void response
public extension APIEndpoint where Response == Void {

    func decode(from: Data) throws -> Response {
        ()
    }
}

/// Default implement for Decodable response
public extension APIEndpoint where Response: Decodable {

    func decode(from data: Data) throws -> Response {
        try (endpoint.decoder ?? JSONDecoder().responseDecoder).decode(Response.self, from: data)
    }
}

/// Default implement for Data response
public extension APIEndpoint where Response == Data {

    func decode(from data: Data) throws -> Response {
        try (endpoint.decoder ?? DataResponseDecoder()).decode(from: data)
    }
}

/// Default implement for Dictionary response
public extension APIEndpoint where Response == [String: Any] {

    func decode(from data: Data) throws -> Response {
        try (endpoint.decoder ?? DictionaryResponseDecoder()).decode(from: data)
    }
}

/// Default implement for String response
public extension APIEndpoint where Response == String {

    func decode(from data: Data) throws -> Response {
        try (endpoint.decoder ?? StringResponseDecoder()).decode(from: data)
    }
}
