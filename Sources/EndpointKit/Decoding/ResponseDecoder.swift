//
//  ResponseDecoder.swift
//  
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// ResponseDecoder decodes data from the response
public protocol ResponseDecoder<Response> {
    associatedtype Response

    func decode(response: URLResponse, data: Data) throws -> Response
}
