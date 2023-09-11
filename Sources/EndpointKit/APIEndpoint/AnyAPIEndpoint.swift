//
//  File.swift
//  
//
//  Created by Burgess, Rick on 9/6/23.
//

import Foundation

/// type erased APIEndpoint
public struct AnyAPIEndpoint<Parameters, Response>: APIEndpoint {
    public var parameters: Parameters
    public var endpoint: Endpoint

    public var parameterEncoder: any ParameterEncoder<Parameters>
    public var responseDecoder: any ResponseDecoder<Response>

    public init(
        parameters: Parameters,
        endpoint: Endpoint,
        parameterEncoder: any ParameterEncoder<Parameters>,
        responseDecoder: any ResponseDecoder<Response>
    ) {
        self.parameters = parameters
        self.endpoint = endpoint
        self.parameterEncoder = parameterEncoder
        self.responseDecoder = responseDecoder
    }

    public init<Endpoint: APIEndpoint>(_ endpoint: Endpoint)
        where Endpoint.Parameters == Parameters, Endpoint.Response == Response {
        self.parameters = endpoint.parameters
        self.endpoint = endpoint.endpoint
        self.parameterEncoder = endpoint.parameterEncoder
        self.responseDecoder = endpoint.responseDecoder
    }
}

public extension APIEndpoint {

    func any() -> AnyAPIEndpoint<Parameters, Response> {
        AnyAPIEndpoint(self)
    }
}
