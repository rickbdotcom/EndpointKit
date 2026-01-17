//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

let defaultAuthorizationKey = "Authorization"

public struct BasicAuthorization: URLRequestModifier {
    let authToken: String
    let key: String

    public init(authToken: String, key: String? = nil) {
        self.authToken = authToken
        self.key = key ?? defaultAuthorizationKey
    }

    public init(userName: String, password: String, key: String? = nil) {
        self = .init(
            authToken: Data([userName, password].joined(separator: ":").utf8).base64EncodedString(),
            key: key ?? defaultAuthorizationKey
        )
    }

    public func callAsFunction(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Basic \(authToken)", forHTTPHeaderField: key)
        return modifiedRequest
    }
}

public struct BearerAuthorization: URLRequestModifier {
    let authToken: String
    let key: String

    public init(authToken: String, key: String? = nil) {
        self.authToken = authToken
        self.key = key ?? defaultAuthorizationKey
    }

    public func callAsFunction(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: key)
        return modifiedRequest
    }
}
