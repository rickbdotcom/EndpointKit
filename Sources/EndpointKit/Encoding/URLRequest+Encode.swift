//
//  URLRequest+Encode.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

public extension URLRequest {

    /// Encode Encodable parameters
    mutating func encode<T: Encodable>(_ parameters: T, with encoder: ParameterEncoder) throws {
        self = try encoder.encode(parameters: parameters, in: self)
    }

    /// Default encode implementation
    mutating func encode<T>(_ parameters: T, with encoder: ParameterEncoder) throws {
        self = try encoder.encode(parameters: parameters, in: self)
    }
}
