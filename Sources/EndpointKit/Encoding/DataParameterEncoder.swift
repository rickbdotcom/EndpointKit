//
//  DataParameterEncoder.swift
//  AmericanCoreNetworking
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// For use with Endpoint parameter is Data, raw data is put directly into HTTP body with no encoding (application/octet-stream by default unless contentType is specified)
public struct DataParameterEncoder: ParameterEncoder {
    public typealias Parameters = Data

    public let contentType: String

    public init(contentType: String = "application/octet-stream") {
        self.contentType = contentType
    }

    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        modifiedRequest.httpBody = parameters
        return modifiedRequest
    }
}
