//
//  EmptyParameterEncoder.swift
//  
//
//  Created by Burgess, Rick on 8/25/23.
//

import Foundation

/// No parameters
public struct EmptyParameterEncoder: RequestEncoder {
    public typealias Parameters = Void

    public init() {
    }
    
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        request
    }
}
