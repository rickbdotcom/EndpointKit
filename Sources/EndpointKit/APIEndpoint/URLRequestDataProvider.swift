//
//  URLSession+APIEndpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// URLSession implements this, can be used for mocking
public protocol URLRequestDataProvider {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

public extension URLRequestDataProvider {

    /// A complete async HTTP request on the specified endpoint
    func request<T: APIEndpoint>(baseURL: URL, endpoint: T) async throws -> T.Response {
        let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
        let (data, response) = try await data(for: request)
        return try await endpoint.responseDecoder.decode(response: response, data: data)
    }
}

extension URLSession: URLRequestDataProvider {
    /// URLSession URLRequestDataProvider conformance
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            return try await data(for: urlRequest, delegate: nil)
        } else { // need to update minimum deployment target to watchOS 8.0 already
            struct UnavailableError: Error { }
            throw UnavailableError()
        }
    }
}
