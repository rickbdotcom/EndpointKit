//
//  DataResponseDecoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Decode response as Data
public struct DataResponseDecoder: ResponseDecoder {

    public func decode<T>(from data: Data) throws -> T {
        guard let response = data as? T else {
            throw DecodeError.responseIsNotData
        }
        return response
    }
}

public extension DataResponseDecoder {
    enum DecodeError: Error {
        case responseIsNotData
    }
}
