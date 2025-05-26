//
//  AnyRequestEncoder.swift
//  
//
//  Created by Burgess, Rick  on 9/6/23.
//

import Foundation

public struct AnyRequestEncoder<Parameters>: RequestEncoder {
    let encode: @Sendable (Parameters, URLRequest) async throws -> URLRequest

    public init(encode: @Sendable @escaping (Parameters, URLRequest) async throws -> URLRequest) {
        self.encode = encode
    }

    public func encode(_ parameters: Parameters, into request: URLRequest) async throws -> URLRequest {
        try await encode(parameters, request)
    }
}
