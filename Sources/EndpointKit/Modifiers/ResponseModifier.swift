//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

/// An endpoint modifier that modifies an endpoint's response
public struct ResponseModifier<Parameters, Response>: EndpointModifier {
    public typealias MapDecoder = (any ResponseDecoder<Response>) -> any ResponseDecoder<Response>
    let responseDecoder: MapDecoder

    /// Create parameter modifier from an existing response encoder
    public init(_ responseDecoder: @escaping MapDecoder) {
        self.responseDecoder = responseDecoder
    }

    /// Implementation of parameter modifier
    public func modify<T: Endpoint>(_ endpoint: T) -> AnyEndpoint<Parameters, Response> 
    where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = endpoint.any()
        let decoder = modifiedEndpoint.responseDecoder
        modifiedEndpoint.responseDecoder = responseDecoder(decoder)
        return modifiedEndpoint
    }
}
