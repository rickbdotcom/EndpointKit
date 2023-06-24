//
//  ParameterEncoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// A ParameterEncoder modifies a URLRequest by encoding the passed in parameters
public protocol ParameterEncoder {
    func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest
    func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest
}

public extension ParameterEncoder {
    /// Default implementation that throws unimplemented error
    func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
        throw ParameterEncoderError.unimplemented
    }

    /// Default implementation that throws unimplemented error
    func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest {
        throw ParameterEncoderError.unimplemented
    }
}

public enum ParameterEncoderError: Error {
    case unimplemented
}
