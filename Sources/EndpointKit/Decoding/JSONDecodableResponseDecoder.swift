//
//  JSONDecodableResponseDecoder.swift
//  
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Decode response as JSON Decodable
public struct JSONDecodableResponseDecoder<T:Decodable>: ResponseDecoder {
    public typealias Response = T

    let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func decode(response: URLResponse, data: Data) throws -> Response {
        try decoder.decode(T.self, from: data)
    }
}
