//
//  AnyParameterEncoder.swift
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
