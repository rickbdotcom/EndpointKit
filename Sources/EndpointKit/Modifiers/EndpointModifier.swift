//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//


import Foundation

/// APIEndpointModifier modifies an endpoint
/// Primary use will be for adding headers to the request and adding error handling for response.
public protocol EndpointModifier<Parameters, Response> {
    associatedtype Parameters
    associatedtype Response

    func modify<T: Endpoint>(_ endpoint: T) -> AnyEndpoint<T.Parameters, T.Response> 
    where T.Parameters == Parameters, T.Response == Response
}

extension Endpoint {

    /// Modify the endpoint with the specified modifier
    public func modify(_ modifier: any EndpointModifier<Parameters, Response>) -> AnyEndpoint<Parameters, Response> {
        modifier.modify(self)
    }

    /// Modify the endpoint with the specified modifier
    public func modify(_ modifier: AnyEndpointModifier<Parameters, Response>) -> AnyEndpoint<Parameters, Response> {
        modifier.modify(self)
    }

    /// Modify the endpoint with the array of modifiers
    public func modify(_ modifiers: [AnyEndpointModifier<Parameters, Response>]) -> AnyEndpoint<Parameters, Response> {
        var endpoint = any()
        for modifier in modifiers {
            endpoint = endpoint.modify(modifier)
        }
        return endpoint
    }

    /// Specifically modify the endpoint's parameterEncoder
    public func modify(parameterEncoder: @escaping (any ParameterEncoder<Parameters>) -> any ParameterEncoder<Parameters>) -> AnyEndpoint<Parameters, Response> {
        var endpoint = any()
        endpoint.parameterEncoder = parameterEncoder(endpoint.parameterEncoder)
        return endpoint
    }

    /// Specifically modify the endpoint's responseDecoder
    public func modify(responseDecoder: @escaping (any ResponseDecoder<Response>) -> any ResponseDecoder<Response>) -> AnyEndpoint<Parameters, Response> {
        var endpoint = any()
        endpoint.responseDecoder = responseDecoder(endpoint.responseDecoder)
        return endpoint
    }
}
