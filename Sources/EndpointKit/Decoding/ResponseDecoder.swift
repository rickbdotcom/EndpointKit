//
//  ResponseDecoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// ResponseDecoder decodes data from the response
public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func decode<T>(from data: Data) throws -> T
}

public extension ResponseDecoder {
    /// Default implementation that throws unimplemented error
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        throw ResponseDecoderError.unimplemented
    }

    /// Default implementation that throws unimplemented error
    func decode<T>(from data: Data) throws -> T {
        throw ResponseDecoderError.unimplemented
    }
}

public enum ResponseDecoderError: Error {
    case unimplemented
}
