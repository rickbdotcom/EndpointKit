//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import XCTest
@testable import EndpointKit

func endpointRequestMatches<T: Endpoint>(
    _ endpoint: T,
    baseURL: URL,
    matchingURL url: String? = nil,
    matchingBody httpBody: String? = nil,
    matchingHeaders headers: [String: String]? = nil
) async throws {
    let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
    if let url {
        try XCTAssertEqual(request.url, XCTUnwrap(URL(string: url)))
    }

    if let httpBody {
        let requestBody = try XCTUnwrap(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        XCTAssertEqual(httpBody, requestBody)
    }

    if let headers {
        let keys = headers.keys
        XCTAssertEqual(headers, request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
    }

// fixme rickb    XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
}

func endpointRequestMatches<T: Endpoint>(
    _ endpoint: T,
    baseURL: URL,
    matchingURL url: String? = nil,
    matchingHeaders headers: [String: String]? = nil,
    decoder: JSONDecoder
) async throws where T.Parameters: Codable & Equatable {

    let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
    if let url {
        try XCTAssertEqual(request.url, XCTUnwrap(URL(string: url)))
    }

    let parameters = try decoder.decode(T.Parameters.self, from: request.httpBody!)
    XCTAssertEqual(endpoint.parameters, parameters)

    if let headers {
        let keys = headers.keys
        XCTAssertEqual(headers, request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
    }

// fixme rickb    XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
}

struct TestDataProvider: URLRequestDataProvider {
    let body: Data
    let statusCode: Int

    init(body: Data = Data(), statusCode: Int = 200) {
        self.body = body
        self.statusCode = statusCode
    }

    init(body: String, statusCode: Int = 200) {
        self.body = body.data(using: .utf8) ?? Data()
        self.statusCode = statusCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try (
            body,
            XCTUnwrap(
                HTTPURLResponse(
                    url: XCTUnwrap(request.url),
                    statusCode: statusCode,
                    httpVersion: "1.1",
                    headerFields: nil
                )
            )
        )
    }
}
