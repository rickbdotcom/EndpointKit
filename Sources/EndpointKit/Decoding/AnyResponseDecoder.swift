//
//  AnyResponseDecoder.swift
//
//  Created by Burgess, Rick on 9/5/23.
//

import Foundation

public struct AnyResponseDecoder<T>: ResponseDecoder {
    public typealias Response = T

    let decode: (URLResponse, Data) async throws -> T

    public init(decode: @escaping (URLResponse, Data) async throws -> T) {
        self.decode = decode
    }

    public func decode(response: URLResponse, data: Data) async throws -> Response {
        try await decode(response, data)
    }
}

public extension ResponseDecoder {

    func validate<T: Error>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T>
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if data.isEmpty == false {
                throw try await decoder.decode(response: response, data: data)
            }
            return try await decode(response: response, data: data)
        }
    }

    func validate<T: Error & Decodable>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T> = JSONDecodableResponseDecoder<T>()
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if data.isEmpty == false {
                throw try await decoder.decode(response: response, data: data)
            }
            return try await decode(response: response, data: data)
        }
    }

    func validateHTTP() -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            try throwInvalidHTTP(response: response, data: data)
            return try await decode(response: response, data: data)
        }
    }
}

/// A basic HTTP error
public struct HTTPError: Error {
    public let data: Data
    public let response: HTTPURLResponse
    public var statusCode: Int { response.statusCode }

    public var localizedDescription: String {
        "HTTP Error: \(statusCode)"
    }
}

/// A default implementation of HTTP handling, throws an error if code is not 2xx - 3xx
public func throwInvalidHTTP(response: URLResponse, data: Data) throws {
    guard let response = response as? HTTPURLResponse else { return }
    let statusCode = response.statusCode
    if statusCode < 200 || statusCode > 399 {
        throw HTTPError(data: data, response: response)
    }
}

