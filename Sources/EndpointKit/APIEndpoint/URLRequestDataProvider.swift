//
//  URLSession+APIEndpoint.swift
//  
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
    func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL, validate: ((Data, URLResponse) throws -> Void)? = nil) async throws -> T.Response {
        let request = try endpoint.request(baseURL: baseURL)
        let (data, response) = try await data(for: request)
        try (validate ?? defaultResponseValidation)(data, response)
        return try endpoint.decode(response: response, data: data)
    }
}

extension URLSession: URLRequestDataProvider {
    /// URLSession URLRequestDataProvider conformance
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            return try await data(for: urlRequest, delegate: nil)
        } else { // need to update minimum deployment target to watchOS 8.0 already
            throw UnavailableError()
        }
    }
}

/// A default implementation of HTTP handling, throws an error if code is not 2xx - 3xx
private func defaultResponseValidation(_ data: Data, _ response: URLResponse) throws {
    guard let response = response as? HTTPURLResponse else { return }
    let statusCode = response.statusCode
    if statusCode < 200 || statusCode > 399 {
        throw HTTPError(data: data, response: response)
    }
}

private struct UnavailableError: Error { }

/// A basic HTTP error
public struct HTTPError: Error {
    public let data: Data
    public let response: HTTPURLResponse
    public var statusCode: Int { response.statusCode }

    public var localizedDescription: String {
        "HTTP Error: \(statusCode)"
    }
}
