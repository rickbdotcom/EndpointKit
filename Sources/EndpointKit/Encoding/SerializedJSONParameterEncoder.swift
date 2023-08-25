//
//  SerializedJSONParameterEncoder.swift
//  
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// When Endpoint parameters are specified as a JSON Encodable Dictionary (application/json)
public struct SerializedJSONParameterEncoder<T>: ParameterEncoder {
    public typealias Parameters = T
    
    public init() { }

    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        return modifiedRequest
    }
}
