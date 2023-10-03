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
        decoder: any ResponseDecoder<T?>
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if let error = try await decoder.decode(response: response, data: data) {
                throw error
            }
            return try await decode(response: response, data: data)
        }
    }

    func validate<T: Error & Decodable>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T?> = JSONDecodableResponseDecoder<T?>()
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if let error = try? await decoder.decode(response: response, data: data) {
                throw error
            }
            return try await decode(response: response, data: data)
        }
    }

    func validateHTTP() -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            try throwIfHttpError(response: response, data: data)
            return try await decode(response: response, data: data)
        }
    }
}
