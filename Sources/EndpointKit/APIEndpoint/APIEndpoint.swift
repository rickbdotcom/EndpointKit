//
//  APIEndpoint.swift
//  
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
public protocol APIEndpoint {
    /// The parameters passed to the endpoint
    associatedtype Parameters = Void
    /// The response expected from the endpoint
    associatedtype Response = Void

    /// parameters
    var parameters: Parameters { get }
    /// endpoint field specifies the path, HTTP method, paramter encoding, response decoding, and any required HTTP headers
    var endpoint: Endpoint { get }

    /// Creates a URL request relative to baseURL passed in
    func request(baseURL: URL) throws -> URLRequest

    /// Decodes the data response from this endpoint
    func decode(response: URLResponse, data: Data) throws -> Response

    /// Specifies how to encode the parameter into a URLRequest
    var parameterEncoder: any ParameterEncoder<Parameters> { get }

    // Specifies how to decode the response
    var responseDecoder: any ResponseDecoder<Response> { get }
}

public protocol APIEndpointClient {
    func request<T: APIEndpoint>(_ endpoint: T) async throws -> T.Response
}

public extension APIEndpoint where Parameters == Void {
    var parameters: Void { () }
}

public extension APIEndpoint {

    func request(baseURL: URL) throws -> URLRequest {
        try parameterEncoder.encode(parameters, into: endpoint.request(baseURL: baseURL))
    }

    func decode(response: URLResponse, data: Data) throws -> Response {
        try responseDecoder.decode(response: response, data: data)
    }
}
