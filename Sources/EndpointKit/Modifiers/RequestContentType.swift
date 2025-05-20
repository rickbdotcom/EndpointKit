//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
    /// Create a modifier that modifies the endpoint's Content-Type
    public static func contentType(_ contentType: String) -> Self {
        RequestModifier {
            $0.contentType(contentType)
        }.any()
    }
}

extension RequestEncoder {
    /// Modify parameter encoder to set content type
    public func contentType(_ contentType: String) -> any RequestEncoder<Parameters> {
        merge(headers: [ContentType.header: contentType])
    }
}
