//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 2/17/25.
//

import Foundation

public protocol Authorization {
    func authorize(request: URLRequest) -> URLRequest
}

let defaultAuthorizationKey = "Authorization"

public struct BearerAuthorization: Authorization {
    let authToken: String
    let key: String

    public init(authToken: String, key: String? = nil) {
        self.authToken = authToken
        self.key = key ?? defaultAuthorizationKey
    }

    public init(userName: String, password: String, key: String? = nil) {
        self = .init(
            authToken: Data([userName, password].joined(separator: ":").utf8).base64EncodedString(),
            key:  key ?? defaultAuthorizationKey
        )
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: key)
        return modifiedRequest
    }
}

public struct BasicAuthorization: Authorization {
    let authToken: String
    let key: String

    public init(authToken: String, key: String? = nil) {
        self.authToken = authToken
        self.key = key ?? defaultAuthorizationKey
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Basic \(authToken)", forHTTPHeaderField: key)
        return modifiedRequest
    }
}

public extension URLRequest {
    mutating func authorize(with authorization: any Authorization) -> Self {
        authorization.authorize(request: self)
    }
}

extension AnyEndpointModifier {
    public static func authorize(with authorization: any Authorization) -> Self {
        RequestModifier {
            $0.authorize(with: authorization)
        }.any()
    }
}

extension RequestEncoder {
    func authorize(with authorization: any Authorization) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            return request.authorize(with: authorization)
        }
    }
}
