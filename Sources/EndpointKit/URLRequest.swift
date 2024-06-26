//
//  URLRequest.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

public extension URLRequest {

    init<T: Endpoint>(baseURL: URL, endpoint: T) async throws {
        self = try await URLRequest(baseURL: baseURL, endpoint: endpoint.route)
                .encode(parameters: endpoint.parameters, with: endpoint.parameterEncoder)
    }

    init(baseURL: URL, endpoint: Route) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        self = request
    }

    func encode<T>(parameters: T, with encoder: any ParameterEncoder<T>) async throws -> URLRequest {
        try await encoder.encode(parameters, into: self)
    }
}
