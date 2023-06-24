//
//  DictionaryParameterEncoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// When Endpoint parameters are specified as a JSON Encodable Dictionary (application/json)
public struct DictionaryParameterEncoder: ParameterEncoder {

    public init() { }

    public func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        return modifiedRequest
    }
}
