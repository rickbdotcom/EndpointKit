//
//  File.swift
//  
//
//  Created by Burgess, Rick  on 9/6/23.
//

import Foundation

public struct AnyParameterEncoder<T>: ParameterEncoder {
    public typealias Parameters = T

    let encode: (Parameters, URLRequest) async throws -> URLRequest

    public init(encode: @escaping (T, URLRequest) async throws -> URLRequest) {
        self.encode = encode
    }

    public func encode(_ parameters: T, into request: URLRequest) async throws -> URLRequest {
        try await encode(parameters, request)
    }
}

public extension ParameterEncoder {

    func add(headers: [String: String]) -> any ParameterEncoder<Parameters> {
        AnyParameterEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            let requestHeaders = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = headers.merging(requestHeaders) { a, _ in a }
            return request
        }
    }
}
