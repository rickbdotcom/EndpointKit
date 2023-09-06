//
//  File.swift
//  
//
//  Created by Burgess, Rick (CHICO-C) on 9/6/23.
//

import Foundation

public protocol APIEndpointModifier {
    func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response>
}

public extension APIEndpoint {

    func modify(_ modifier: APIEndpointModifier) -> AnyAPIEndpoint<Parameters, Response> {
        modifier.modify(self).any()
    }

    func modify(_ modifiers: [APIEndpointModifier]) -> AnyAPIEndpoint<Parameters, Response> {
        var endpoint = AnyAPIEndpoint(self)
        for modifier in modifiers  {
            endpoint = endpoint.modify(modifier)
        }
        return endpoint
    }
}

public extension APIEndpointModifier where Self == APIEndpointParameterModifier {
    static func headers(_ headers: [String : String]) -> Self {
        guard #available(iOS 16.0.0, watchOS 9.0.0, macOS 13.0.0, *) else { fatalError() }
        return APIEndpointParameterModifier { $0.add(headers: headers) }
    }
}

public extension APIEndpointModifier where Self == APIEndpointResponseModifier {

    static func validateHTTP() -> Self {
        guard #available(iOS 16.0.0, watchOS 9.0.0, macOS 13.0.0, *) else { fatalError() }
        return APIEndpointResponseModifier { $0.validateHTTP() }
    }
}

public struct APIEndpointParameterModifier: APIEndpointModifier {
    let parameterEncoder: (any ParameterEncoder) -> any ParameterEncoder

    public init(_ parameterEncoder: @escaping (any ParameterEncoder) -> any ParameterEncoder) {
        self.parameterEncoder = parameterEncoder
    }

    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response> {
        guard #available(iOS 16.0.0, watchOS 9.0.0, macOS 13.0.0, *) else { fatalError() }

        var modifiedEndpoint = apiEndpoint.any()
        let encoder = modifiedEndpoint.parameterEncoder
        if let modifiedEncoder = parameterEncoder(encoder) as? (any ParameterEncoder<T.Parameters>) {
            modifiedEndpoint.parameterEncoder = modifiedEncoder
        }
        return modifiedEndpoint
    }
}

public struct APIEndpointResponseModifier: APIEndpointModifier {
    let responseDecoder: (any ResponseDecoder) -> any ResponseDecoder

    public init(_ responseDecoder: @escaping (any ResponseDecoder) -> any ResponseDecoder) {
        self.responseDecoder = responseDecoder
    }

    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response> {
        guard #available(iOS 16.0.0, watchOS 9.0.0, macOS 13.0.0, *) else { fatalError() }

        var modifiedEndpoint = apiEndpoint.any()
        let decoder = modifiedEndpoint.responseDecoder
        if let modifiedDecoder = responseDecoder(decoder) as? (any ResponseDecoder<T.Response>) {
            modifiedEndpoint.responseDecoder = modifiedDecoder
        }
        return modifiedEndpoint
    }
}
