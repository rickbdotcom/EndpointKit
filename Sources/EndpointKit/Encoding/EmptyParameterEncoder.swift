//
//  File.swift
//  
//
//  Created by Burgess, Rick on 8/25/23.
//

import Foundation

/// No parameters
struct EmptyParameterEncoder: ParameterEncoder {
    typealias Parameters = Void

    func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        request
    }
}
