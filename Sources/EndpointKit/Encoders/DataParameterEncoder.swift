//
//  DataParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// For use when Endpoint parameter is Data.
/// Raw data is put directly into HTTP body with no encoding
public struct DataParameterEncoder: RequestEncoder {
    public typealias Parameters = Data

    public init() {
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(ContentType.octetStream.description, forHTTPHeaderField: ContentType.header)
        modifiedRequest.httpBody = parameters
        return modifiedRequest
    }
}
