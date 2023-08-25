//
//  EndpointTests.swift
//  AmericanCoreNetworkingTests
//
//  Created by rickb on 6/14/23.
//
//

import Foundation
import XCTest
@testable import EndpointKit

enum API {
    struct Login: APIEndpoint {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }

        struct Response: Decodable, Equatable {
            let accessToken: String
            let refreshToken: String
        }

        let endpoint: Endpoint = "POST /login"
        var parameters: Parameters
    }

    struct Track: APIEndpoint {
        struct Parameters: Encodable {
            let action: String
        }
        typealias Response = Void

        let endpoint = Endpoint("/track", .get, headers: headers)
        var parameters: Parameters
    }

    struct Form: APIEndpoint {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }
        typealias Response = String

        let endpoint: Endpoint = "POST /form"
        var parameters: Parameters

        var parameterEncoder: any ParameterEncoder<Parameters> {
            FormParameterEncoder()
        }
    }

    struct Poll: APIEndpoint {
        let pollId: String
        typealias Parameters = [String: Any]
        typealias Response = [String: Int]

        var endpoint: Endpoint { .init("/poll/\(pollId)", .post) }
        var parameters: Parameters

        var parameterEncoder: any ParameterEncoder<Parameters> {
            SerializedJSONParameterEncoder()
        }
        var responseDecoder: any ResponseDecoder<Response> {
            SerializedJSONResponseDecoder()
        }
    }

    struct ImageUpload: APIEndpoint {
        typealias Parameters = Data
        typealias Response = Void

        let endpoint: Endpoint = "POST /upload"
        var parameters: Parameters
    }

    struct ImageDownload: APIEndpoint {
        typealias Response = Data

        let endpoint: Endpoint = "GET /download"
    }

    static let baseURL = URL(string: "https://www.aa.com")!

    static let headers = ["pageName": "home"]
}

final class EndpointTests: XCTestCase {

    func testJSONParameterEncoder() async throws {
        try endpointRequestMatches(
            API.Login(parameters: .init(
                username: "traveler123", password: "test123"
            )),
            baseURL: API.baseURL,
            matchingURL: "https://www.aa.com/login",
            matchingBody: "{\"username\":\"traveler123\",\"password\":\"test123\"}"
        )
    }

    func testURLParameterEncoder() async throws {
        try endpointRequestMatches(
            API.Track(parameters: .init(
                action: "login"
            )),
            baseURL: API.baseURL,
            matchingURL: "https://www.aa.com/track?action=login"
        )
    }

    func testFormParameterEncoder() async throws {
        try endpointRequestMatches(
            API.Form(parameters: .init(
                username: "traveler123", password: "test123"
            )),
            baseURL: API.baseURL,
            matchingURL: "https://www.aa.com/form",
            matchingBody: "password=test123&username=traveler123"
        )
    }

    func testDictionaryParameterEncoder() async throws {
        try endpointRequestMatches(
            API.Poll(pollId: "1", parameters: ["blueGoldDress": "blue"]),
            baseURL: API.baseURL,
            matchingURL: "https://www.aa.com/poll/1",
            matchingBody: "{\"blueGoldDress\":\"blue\"}"
        )
    }

    func testDataParameterEncoder() async throws {
        try endpointRequestMatches(
            API.ImageUpload(parameters: "123".data(using: .utf8)!), // swiftlint:disable:this force_unwrap
            baseURL: API.baseURL,
            matchingURL: "https://www.aa.com/upload",
            matchingBody: "123"
        )
    }

    func testVoidParameters() async throws {
        let imageDownload = API.ImageDownload()
        let request = try imageDownload.request(baseURL: API.baseURL)
        XCTAssertEqual(request.httpBody, nil)
    }

    func testHeaders() async throws {
        try endpointRequestMatches(
            API.Track(parameters: .init(
                action: "login"
            )),
            baseURL: API.baseURL,
            matchingHeaders: ["pageName": "home"]
        )
    }

    func testJSONResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "{\"accessToken\": \"123\", \"refreshToken\": \"456\"}")
        let login = API.Login(parameters: .init(
            username: "traveler123", password: "test123"
        ))
        let result = try await dataProvider.request(login, baseURL: API.baseURL)
        XCTAssertEqual(result, API.Login.Response(accessToken: "123", refreshToken: "456"))
    }

    func testDictionaryResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "{\"blue\": 10, \"gold\": 5}")
        let poll = API.Poll(pollId: "1", parameters: ["blueGoldDress": "blue"])
        let result = try await dataProvider.request(poll, baseURL: API.baseURL)
        XCTAssertEqual(result, ["blue": 10, "gold": 5])
    }

    func testDataResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let imageDownload = API.ImageDownload()
        let result = try await dataProvider.request(imageDownload, baseURL: API.baseURL)
        XCTAssertEqual("123", String(data: result, encoding: .utf8))
    }

    func testStringResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let form = API.Form(parameters: .init(
            username: "traveler123", password: "test123"
        ))
        let result = try await dataProvider.request(form, baseURL: API.baseURL)
        XCTAssertEqual("123", result)
    }

    func testVoidResponse() async throws {
        let dataProvider = TestDataProvider()
        let track = API.Track(parameters: .init(
            action: "login"
        ))
        try await dataProvider.request(track, baseURL: API.baseURL)
    }

    func testCustomValidator() async throws {
        let dataProvider = TestDataProvider(body: "{\"errorCode\": 1}")
        let track = API.Track(parameters: .init(
            action: "login"
        ))

        struct CustomError: Error, Decodable {
            let errorCode: Int
        }

        do {
            try await dataProvider.request(track, baseURL: API.baseURL) { data, response in
                if let error = try? JSONDecoder().decode(CustomError.self, from: data) {
                    throw error
                }
            }
            XCTFail("Should have failed")
        } catch let error as CustomError {
            XCTAssertEqual(error.errorCode, 1)
        } catch {
            XCTFail("unknown error")
        }
    }
}

func endpointRequestMatches<T: APIEndpoint>(_ endpoint: T, baseURL: URL, matchingURL url: String? = nil, matchingBody httpBody: String? = nil, matchingHeaders headers: [String: String]? = nil) throws {
    let request = try endpoint.request(baseURL: baseURL)
    if let url {
        XCTAssertEqual(request.url, URL(string: url)!)  // swiftlint:disable:this force_unwrap
    }

    if let httpBody {
        let requestBody = try XCTUnwrap(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        XCTAssertEqual(httpBody, requestBody)
    }

    if let headers {
        let keys = headers.keys
        XCTAssertEqual(headers, request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
    }

    XCTAssertEqual(request.httpMethod, endpoint.endpoint.method.rawValue)
}

struct TestDataProvider: URLRequestDataProvider {
    let body: String
    let statusCode: Int

    init(body: String = "", statusCode: Int = 200) {
        self.body = body
        self.statusCode = statusCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        (body.data(using: .utf8) ?? Data(), HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.1", headerFields: nil)!) // swiftlint:disable:this force_unwrap
    }
}
