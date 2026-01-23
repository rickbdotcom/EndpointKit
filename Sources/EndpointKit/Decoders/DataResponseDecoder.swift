//
//  DataResponseDecoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Returns data from response directly
public struct DataResponseDecoder: ResponseDecoder {
    public typealias Response = Data
    
    public init() {
    }
    
    public func decode(response: URLResponse, data: Data) throws -> Response {
        data
    }
}
