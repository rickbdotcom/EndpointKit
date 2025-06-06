//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import Testing
@testable import EndpointKit

extension URL {
    static let test = URL(string: "https://www.rickb.com")!
}

extension URLRequest {
    static let test = URLRequest(url: .test)
}

extension Date {
    static let test = Date(timeIntervalSince1970: 0)
}

extension Endpoint {
    func requestMatches(
        url: String? = nil,
        body: String? = nil,
        headers: [String: String]? = nil
    ) async throws {
        let request = try await URLRequest(baseURL: .test, endpoint: self)

        if let url {
            let requestURL = try #require(URL(string: url))
            #expect(request.url == requestURL)
        }

        if let body {
            #expect(body == request.body)
        }

        if let headers {
            print(headers)
            #expect(headers == request.allHTTPHeaderFields)
        }

        #expect(request.httpMethod == route.method.rawValue)
    }
}

extension Endpoint where Parameters: Codable & Equatable {

    func requestMatches(
        url: String? = nil,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws {
        let request = try await URLRequest(baseURL: .test, endpoint: self)
        if let url {
            let requestURL = try #require(URL(string: url))
            #expect(request.url == requestURL)
        }

        let parameters = try decoder.decode(Parameters.self, from: request.httpBody!)
        #expect(self.parameters == parameters)

        if let headers {
            let keys = headers.keys
            #expect(headers == request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
        }

        #expect(request.httpMethod == route.method.rawValue)
    }
}

struct TestClient: EndpointClient, URLRequestDataProvider {
    var body: Data
    var statusCode: Int

    init(body: Data = Data(), statusCode: Int = 200) {
        self.body = body
        self.statusCode = statusCode
    }

    init(body: String, statusCode: Int = 200) {
        self.body = Data(body.utf8)
        self.statusCode = statusCode
    }

    func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        try await request(baseURL: .test, endpoint: endpoint)
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

extension URLRequest {

    var body: String? {
        if let httpBody,
           let string = String(data: httpBody, encoding: .utf8) {
            string
        } else {
            nil
        }
    }
}
