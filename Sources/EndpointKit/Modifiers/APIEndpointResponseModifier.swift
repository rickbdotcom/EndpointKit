//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

/// An endpoint modifier that modifies an endpoint's response
public struct APIEndpointResponseModifier<Parameters, Response>: APIEndpointModifier {
    public typealias MapDecoder = (any ResponseDecoder<Response>) -> any ResponseDecoder<Response>
    let responseDecoder: MapDecoder

    /// Create parameter modifier from an existing response encoder
    public init(_ responseDecoder: @escaping MapDecoder) {
        self.responseDecoder = responseDecoder
    }

    /// Create parameter modifier from function
    public init(_ decode: @escaping (any ResponseDecoder<Response>, URLResponse, Data) async throws -> Response) {
        responseDecoder = { decoder in
            AnyResponseDecoder { response, data in
                try await decode(decoder, response, data)
            }
        }
    }

    /// Implementation of parameter modifier
    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<Parameters, Response> 
    where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = apiEndpoint.any()
        let decoder = modifiedEndpoint.responseDecoder
        modifiedEndpoint.responseDecoder = responseDecoder(decoder)
        return modifiedEndpoint
    }
}
