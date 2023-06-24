//
//  JSONResponseDecoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Decode response as JSON Decodable
public extension JSONDecoder {

    var responseDecoder: ResponseDecoder {
        JSONResponseDecoder(decoder: self)
    }
}

struct JSONResponseDecoder: ResponseDecoder {
    let decoder: JSONDecoder

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        try decoder.decode(type, from: data)
    }
}
