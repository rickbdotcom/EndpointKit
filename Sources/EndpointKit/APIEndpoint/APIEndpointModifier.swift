////
//  File.swift
//
//
//  Created by Burgess, Rick  on 9/6/23.
//

import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
public protocol APIEndpointModifier<Parameters, Response> {
    associatedtype Parameters
    associatedtype Response

    func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response> where T.Parameters == Parameters, T.Response == Response
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
public extension APIEndpoint {

    func modify(_ modifier: any APIEndpointModifier<Parameters, Response>) -> AnyAPIEndpoint<Parameters, Response> {
        modifier.modify(self)
    }

    func modify(_ modifiers: [any APIEndpointModifier<Parameters, Response>]) -> AnyAPIEndpoint<Parameters, Response> {
        var endpoint = any()
        for modifier in modifiers {
            endpoint = endpoint.modify(modifier)
        }
        return endpoint
    }

    func modify(parameterEncoder: @escaping (any ParameterEncoder<Parameters>) -> any ParameterEncoder<Parameters>) -> AnyAPIEndpoint<Parameters, Response> {
        var endpoint = any()
        endpoint.parameterEncoder = parameterEncoder(endpoint.parameterEncoder)
        return endpoint
    }

    func modify(responseDecoder: @escaping (any ResponseDecoder<Response>) -> any ResponseDecoder<Response>) -> AnyAPIEndpoint<Parameters, Response> {
        var endpoint = any()
        endpoint.responseDecoder = responseDecoder(endpoint.responseDecoder)
        return endpoint
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
func headerModifier<Parameters, Response>(_ headers: [String : String]) -> some APIEndpointModifier<Parameters, Response> {
    return APIEndpointParameterModifier<Parameters, Response> { $0.add(headers: headers) }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
func validateHTTPModifier<Parameters, Response>() -> some APIEndpointModifier<Parameters, Response> {
    return APIEndpointResponseModifier<Parameters, Response> { $0.validateHTTP() }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
public struct APIEndpointParameterModifier<Parameters, Response>: APIEndpointModifier {
    public typealias MapEncoder = (any ParameterEncoder<Parameters>) -> any ParameterEncoder<Parameters>
    let parameterEncoder: MapEncoder

    public init(_ parameterEncoder: @escaping MapEncoder) {
        self.parameterEncoder = parameterEncoder
    }

    public init(_ encode: @escaping (any ParameterEncoder<Parameters>, Parameters, URLRequest) async throws -> URLRequest) {
        parameterEncoder = { encoder in
            AnyParameterEncoder { parameters, request in
                try await encode(encoder, parameters, request)
            }
        }
    }

    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<T.Parameters, T.Response> where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = apiEndpoint.any()
        let encoder = parameterEncoder(modifiedEndpoint.parameterEncoder)
        modifiedEndpoint.parameterEncoder = encoder
        return modifiedEndpoint
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
public struct APIEndpointResponseModifier<Parameters, Response>: APIEndpointModifier {
    public typealias MapDecoder = (any ResponseDecoder<Response>) -> any ResponseDecoder<Response>
    let responseDecoder: MapDecoder

    public init(_ responseDecoder: @escaping MapDecoder) {
        self.responseDecoder = responseDecoder
    }

    public init(_ decode: @escaping (any ResponseDecoder<Response>, URLResponse, Data) async throws -> Response) {
        responseDecoder = { decoder in
            AnyResponseDecoder { response, data in
                try await decode(decoder, response, data)
            }
        }
    }

    public func modify<T: APIEndpoint>(_ apiEndpoint: T) -> AnyAPIEndpoint<Parameters, Response> where T.Parameters == Parameters, T.Response == Response {
        var modifiedEndpoint = apiEndpoint.any()
        let decoder = modifiedEndpoint.responseDecoder
        modifiedEndpoint.responseDecoder = responseDecoder(decoder)
        return modifiedEndpoint
    }
}
