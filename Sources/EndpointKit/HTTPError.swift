//
//  HTTPError.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

/// A basic HTTP error
public struct HTTPError: LocalizedError {
    /// The data in the response that produced this error
    public let data: Data

    /// The response associated with this error
    public let response: HTTPURLResponse

    /// The HTTP status code from the response
    public var statusCode: Int { response.httpStatusCode }

    /// Implementation of Error localized description
    public var errorDescription: String? {
        "HTTP Error: \(statusCode)"
    }

    /// A default implementation of HTTP handling, throws an error if code is not 2xx
    public static func throwIfError(response: URLResponse, data: Data) throws {
        guard let response = response as? HTTPURLResponse else { return }
        if response.isHttpError {
            throw HTTPError(data: data, response: response)
        }
    }

    /// Determine if the status code is an HTTP error (not 2xx)
    ///
    /// - Parameter _: The HTTP status code
    /// - Returns: If this is an HTTP error
    public static func isError(_ statusCode: Int) -> Bool {
        (200..<300).contains(statusCode) == false
    }

    public var responseString: String? {
        .init(data: data, encoding: .utf8)
    }
}

extension URLResponse {

    /// The HTTP status code of the response
    public var httpStatusCode: Int {
        (self as? HTTPURLResponse)?.statusCode ?? 0
    }

    /// If this response is an HTTP error
    public var isHttpError: Bool {
        HTTPError.isError(httpStatusCode)
    }
}
