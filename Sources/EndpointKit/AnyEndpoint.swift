//
//  AnyAPIEndpoint.swift
//  
//
//  Created by Burgess, Rick on 9/6/23.
//

import Foundation

/// type erased Endpoint
public struct AnyEndpoint<Parameters, Response>: Endpoint {
    public var parameters: Parameters
    public var route: Route

    public var parameterEncoder: any ParameterEncoder<Parameters>
    public var responseDecoder: any ResponseDecoder<Response>

    public init(
        parameters: Parameters,
        route: Route,
        parameterEncoder: any ParameterEncoder<Parameters>,
        responseDecoder: any ResponseDecoder<Response>
    ) {
        self.parameters = parameters
        self.route = route
        self.parameterEncoder = parameterEncoder
        self.responseDecoder = responseDecoder
    }

    public init<T: Endpoint>(_ endpoint: T)
        where T.Parameters == Parameters, T.Response == Response {
        self.parameters = endpoint.parameters
        self.route = endpoint.route
        self.parameterEncoder = endpoint.parameterEncoder
        self.responseDecoder = endpoint.responseDecoder
    }
}

public extension Endpoint {

    func any() -> AnyEndpoint<Parameters, Response> {
        AnyEndpoint(self)
    }
}
