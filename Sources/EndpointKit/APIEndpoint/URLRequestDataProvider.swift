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
