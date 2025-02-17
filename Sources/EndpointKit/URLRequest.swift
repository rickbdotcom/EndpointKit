//
//  URLRequest.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

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

    init(
        baseURL: URL,
        endpoint: Route,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0
    ) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.method.rawValue
        self = request
    }

    func encode<T>(parameters: T, with encoder: any RequestEncoder<T>) async throws -> URLRequest {
        try await encoder.encode(parameters, into: self)
    }
}
