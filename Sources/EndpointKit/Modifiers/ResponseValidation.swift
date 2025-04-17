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
        ResponseModifier { $0.validateHTTP() }.any()
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
}
