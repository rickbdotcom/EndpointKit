//
//  DataParameterEncoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// For use with Endpoint parameter is Data, raw data is put directly into HTTP body with no encoding (application/octet-stream by default unless contentType is specified)
public struct DataParameterEncoder: ParameterEncoder {
    public let contentType: String

    public init(contentType: String = "application/octet-stream") {
        self.contentType = contentType
    }

    public func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest {
        guard let parameters = parameters as? Data else {
            throw EncodeError.parameterIsNotData
        }
        var modifiedRequest = request
        modifiedRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = parameters
        return modifiedRequest
    }
}

public extension DataParameterEncoder {
    enum EncodeError: Error {
        case parameterIsNotData
    }
}
