//
//  File.swift
//  EndpointKit
//
//  Created by Richard Burgess on 12/10/25.
//

import Foundation

public protocol URLRequestModifier {
    func modify(_ request: URLRequest) async throws -> URLRequest 
}

public extension AnyEndpointModifier {
    
    static func modify(_ modifier: any URLRequestModifier) -> AnyEndpointModifier {
        RequestModifier { encoder, parameters, request in
            try await modifier.modify(encoder.encode(parameters, into: request))
        }.any()
    }
}
