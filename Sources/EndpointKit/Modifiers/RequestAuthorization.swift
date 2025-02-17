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

public struct BearerAuthorization: Authorization {
    let authToken: String

    public init(authToken: String) {
        self.authToken = authToken
    }

    public init(userName: String, password: String) {
        self.authToken = Data(base64Encoded: [userName, password].joined(separator: ":"))?.base64EncodedString() ?? ""
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Basic \(authToken)", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
}

public struct BasicAuthorization: Authorization {
    let authToken: String

    public init(authToken: String) {
        self.authToken = authToken
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
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
        RequestModifier { $0.authorize(with: authorization) }.any()
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
