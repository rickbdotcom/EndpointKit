//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import Testing
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
        let requestURL = try #require(URL(string: url))
        #expect(request.url == requestURL)
    }

    if let httpBody {
        let requestBody = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(httpBody == requestBody)
    }

    if let headers {
        let keys = headers.keys
        #expect(headers == request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
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
        let requestURL = try #require(URL(string: url))
        #expect(request.url == requestURL)
    }

    let parameters = try decoder.decode(T.Parameters.self, from: request.httpBody!)
    #expect(endpoint.parameters == parameters)

    if let headers {
        let keys = headers.keys
        #expect(headers == request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
    }

// fixme rickb    XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
}

struct TestDataProvider: URLRequestDataProvider {
    var body: Data
    var statusCode: Int

    init(body: Data = Data(), statusCode: Int = 200) {
        self.body = body
        self.statusCode = statusCode
    }

    init(body: String, statusCode: Int = 200) {
        self.body = body.data(using: .utf8) ?? Data()
        self.statusCode = statusCode
    }

    func request<T: Endpoint>(endpoint: T) async throws -> T.Response {
        try await request(baseURL: .init(string: "https://www.rickb.com")!, endpoint: endpoint)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let url = try #require(request.url)
        let response = try #require(
            HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "1.1",
                headerFields: nil
            )
        )
        return (body, response)
    }
}

struct TestEmptyEndpoint: Endpoint {
    typealias Response = Void
    let route: Route

    init(_ method: HTTPMethod = .get, path: String = #function) {
        route = .init(method, path)
    }
}
