//
//  AnyResponseDecoder.swift
//
//  Created by Burgess, Rick on 9/5/23.
//

import Foundation

public struct AnyResponseDecoder<T>: ResponseDecoder {
    public typealias Response = T

    let decode: @Sendable (URLResponse, Data) async throws -> T

    public init(decode: @Sendable @escaping (URLResponse, Data) async throws -> T) {
        self.decode = decode
    }

    public func decode(response: URLResponse, data: Data) async throws -> Response {
        try await decode(response, data)
    }
}
