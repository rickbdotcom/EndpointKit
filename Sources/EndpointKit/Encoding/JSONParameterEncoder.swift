//
//  JSONParameterEncoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Encodes parameter into body as JSON (application/json)
extension JSONEncoder {

    public func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = try encode(parameters)
        return modifiedRequest
    }
}

public extension JSONEncoder {
    var parameterEncoder: ParameterEncoder {
        JSONParameterEncoder(encoder: self)
    }
}

struct JSONParameterEncoder: ParameterEncoder {
    let encoder: JSONEncoder

    func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest where T : Encodable {
        try encoder.encode(parameters: parameters, in: request)
    }
}
