//
//  Endpoint.swift
//
//  Created by Richard Burgess on 6/13/2023
//
//

import Foundation

public protocol Endpoint<Parameters, Response>: Sendable {
    /// The parameters passed to the endpoint
    associatedtype Parameters: Sendable
    /// The response expected from the endpoint
    associatedtype Response: Sendable

    /// parameters
    var parameters: Parameters { get }
    /// route field specifies the path, HTTP method, parameter encoding, response decoding, and any required HTTP headers
    var route: Route { get }

    /// Specifies how to encode the URLRequest
    var requestEncoder: any RequestEncoder<Parameters> { get }

    // Specifies how to decode the response
    var responseDecoder: any ResponseDecoder<Response> { get }
}

public extension Endpoint where Parameters == Void {
    var parameters: Void { () }
}

public protocol EndpointClient {
    func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

public extension URLRequest {

    init<T: Endpoint>(
        baseURL: URL,
        endpoint: T,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0
    ) async throws {
        self = try await URLRequest(
            baseURL: baseURL,
            endpoint: endpoint.route,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval
        )
        .encode(parameters: endpoint.parameters, with: endpoint.requestEncoder)
    }
}
