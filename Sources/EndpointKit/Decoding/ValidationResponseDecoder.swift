//
//  ValidationResponseDecoder.swift
//
//  Created by Burgess, Rick on 9/5/23.
//

import Foundation

public struct ValidationResponseDecoder<T>: ResponseDecoder {
    public typealias Response = T

    let decoder: any ResponseDecoder<T>
    let validation: (URLResponse, Data) throws -> Void

    public init(decoder: any ResponseDecoder<T>, validation: @escaping (URLResponse, Data) throws -> Void) {
        self.decoder = decoder
        self.validation = validation
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        try validation(response, data)
        return try decoder.decode(response: response, data: data)
    }
}

public extension ResponseDecoder {

    func validate(_ block: @escaping (URLResponse, Data) throws -> Void) -> some ResponseDecoder<Response> {
        ValidationResponseDecoder(decoder: self, validation: block)
    }

    func httpValidate() -> some ResponseDecoder<Response> {
        validate(httpResponseValidation)
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
public func httpResponseValidation(response: URLResponse, data: Data) throws {
    guard let response = response as? HTTPURLResponse else { return }
    let statusCode = response.statusCode
    if statusCode < 200 || statusCode > 399 {
        throw HTTPError(data: data, response: response)
    }
}

