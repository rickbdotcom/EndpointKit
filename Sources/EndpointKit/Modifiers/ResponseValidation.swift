//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
    /// Create a modifier that verifies the response is a non-error HTTP code
    public static func validateHTTP() -> Self {
        ResponseModifier {
            $0.validateHTTP()
        }.any()
    }

    public static func validate<T: Error>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T?>,
        requireHttpError: Bool = true
    ) -> Self {
        ResponseModifier {
            $0.validate(error: error, decoder: decoder, requireHttpError: requireHttpError)
        }.any()
    }

    public static func validate<T: Error & Decodable>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T?> = JSONDecodableResponseDecoder<T?>(),
        requireHttpError: Bool = true
    ) -> Self {
        ResponseModifier {
            $0.validate(error: error, decoder: decoder, requireHttpError: requireHttpError)
        }.any()
    }
}

extension ResponseDecoder {

    /// Modify response decoder to validate HTTP error code of response
    public func validateHTTP() -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            try HTTPError.throwIfError(response: response, data: data)
            return try await decode(response: response, data: data)
        }
    }

    /// Modify response decoder to validate a response using the error
    public func validate<T: Error>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T?>,
        requireHttpError: Bool = true
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if requireHttpError == false || response.isHttpError,
               let error = try? await decoder.decode(response: response, data: data) {
                throw error
            }
            return try await decode(response: response, data: data)
        }
    }

    /// Modify response decoder to validate error that is Decodable
    public func validate<T: Error & Decodable>(
        error: T.Type = T.self,
        decoder: any ResponseDecoder<T?> = JSONDecodableResponseDecoder<T?>(),
        requireHttpError: Bool = true
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            if requireHttpError == false || response.isHttpError,
               let error = try? await decoder.decode(response: response, data: data) {
                throw error
            }
            return try await decode(response: response, data: data)
        }
    }
}
