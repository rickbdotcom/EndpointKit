//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

extension AnyEndpointModifier {
    /// Create a modifier that verifies the response is a non-error HTTP code
    public static func validateHTTP() -> Self {
        ResponseModifier { $0.validateHTTP() }.any()
    }
}
