//
//  AnyResponseDecoder.swift
//
//  Created by Burgess, Rick on 9/5/23.
//

import Foundation

public struct AnyResponseDecoder<Response>: ResponseDecoder {
    let decode: @Sendable (URLResponse, Data) async throws -> Response

    public init(decode: @Sendable @escaping (URLResponse, Data) async throws -> Response) {
        self.decode = decode
    }

    public func decode(response: URLResponse, data: Data) async throws -> Response {
        try await decode(response, data)
    }
}
