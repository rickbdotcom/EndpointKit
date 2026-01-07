//
//  File.swift
//  EndpointKit
//
//  Created by Richard Burgess on 11/17/25.
//

import Foundation

extension ResponseDecoder {

    public func map (
        _ replace: @Sendable @escaping (Response) async throws -> Response
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            try await replace(decode(response: response, data: data))
        }
    }

    public func replaceError(
        _ replace: @Sendable @escaping (Error) async throws -> Response
    ) -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            do {
                return try await decode(response: response, data: data)
            } catch {
                return try await replace(error)
            }
        }
    }
}
