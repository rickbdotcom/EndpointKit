//
//  APIEndpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

/// This protocol represents an API endpoint
/// Additional data can be added to concrete implementations to fully construct the endpoint if needed
/// For example:
/// struct MemberProfile: APIEndpoint {
///     let memberId: String
///     var endpoint: Endpoint { .init("member/\(memberId)/profile", ...) }
///     ...
/// }
public protocol APIEndpoint<Parameters, Response> {
    /// The parameters passed to the endpoint
    associatedtype Parameters
    /// The response expected from the endpoint
    associatedtype Response

    /// parameters
    var parameters: Parameters { get }
    /// endpoint field specifies the path, HTTP method, paramter encoding, response decoding, and any required HTTP headers
    var endpoint: Endpoint { get }

    /// Specifies how to encode the parameter into a URLRequest
    var parameterEncoder: any ParameterEncoder<Parameters> { get }

    // Specifies how to decode the response
    var responseDecoder: any ResponseDecoder<Response> { get }
}

public extension APIEndpoint where Parameters == Void {
    var parameters: Void { () }
}

public protocol APIEndpointClient {
    func request<T: APIEndpoint>(_ endpoint: T) async throws -> T.Response
}
