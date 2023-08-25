//
//  File.swift
//  
//
//  Created by Burgess, Rick
//

import Foundation

/// Empty Response
struct EmptyResponseDecoder: ResponseDecoder {
    public typealias Response = Void

    public func decode(response: URLResponse, data: Data) throws -> Response {
    }
}
