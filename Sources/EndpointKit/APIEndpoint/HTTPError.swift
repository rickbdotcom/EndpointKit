//
//  HTTPError.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

/// A basic HTTP error
public struct HTTPError: Error {
    public let data: Data
    public let response: HTTPURLResponse
    public var statusCode: Int { response.statusCode }

    public var localizedDescription: String {
        "HTTP Error: \(statusCode)"
    }
}

public extension URLResponse {
    var httpStatusCode: Int? {
        (self as? HTTPURLResponse)?.statusCode
    }

    var isHttpError: Bool {
        guard let httpStatusCode else {
            return false
        }
        return httpStatusCodeIsError(httpStatusCode)
    }
}

/// A default implementation of HTTP handling, throws an error if code is not 2xx - 3xx
public func throwIfHttpError(response: URLResponse, data: Data) throws {
    guard let response = response as? HTTPURLResponse else { return }
    if response.isHttpError {
        throw HTTPError(data: data, response: response)
    }
}

public func httpStatusCodeIsError(_ statusCode: Int) -> Bool {
    statusCode < 200 || statusCode > 399
}

