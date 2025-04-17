//
//  File.swift
//  
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

extension ResponseDecoder {

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
