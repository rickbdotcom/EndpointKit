//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import Testing
@testable import EndpointKit

struct RequestAuthorization {

    @Test func bearer() async throws {
        try await TestEmptyEndpoint()
            .modify(.authorize(with: BearerAuthorization(userName: "rickb", password: "test", key: "key")))
            .requestMatches(
                headers: ["key": "Bearer cmlja2I6dGVzdA=="]
            )

        try await TestEmptyEndpoint()
            .modify(.authorize(with: BearerAuthorization(userName: "rickb", password: "test")))
            .requestMatches(
                headers: ["Authorization": "Bearer cmlja2I6dGVzdA=="]
            )

        try await TestEmptyEndpoint()
            .modify(.authorize(with: BearerAuthorization(authToken: "cmlja2I6dGVzdA==")))
            .requestMatches(
                headers: ["Authorization": "Bearer cmlja2I6dGVzdA=="]
            )
    }

    @Test func basic() async throws {
        try await TestEmptyEndpoint()
            .modify(.authorize(with: BasicAuthorization(authToken: "token", key: "key")))
            .requestMatches(
                headers: ["key": "Basic token"]
            )

        try await TestEmptyEndpoint()
            .modify(.authorize(with: BasicAuthorization(authToken: "token")))
            .requestMatches(
                headers: ["Authorization": "Basic token"]
            )
    }
}

struct RequestCachePolicy {

    @Test(arguments: [
            URLRequest.CachePolicy.useProtocolCachePolicy,
            .reloadIgnoringLocalCacheData,
            .reloadIgnoringLocalAndRemoteCacheData,
            .returnCacheDataElseLoad,
            .returnCacheDataDontLoad,
            .reloadRevalidatingCacheData
        ]
    ) func cachePolicy(cachePolicy: URLRequest.CachePolicy) async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.cachePolicy(cachePolicy))

        let request = try await URLRequest(baseURL: testBaseURL, endpoint: endpoint)
        #expect(request.cachePolicy == cachePolicy)
    }
}

struct RequestContentType {

    @Test func contentType() async throws {
        try await TestEmptyEndpoint()
            .modify(.contentType("text/html"))
            .requestMatches(
                headers: ["Content-Type": "text/html"]
            )
    }
}

struct RequestcURL {

    @Test func curlPOST() async throws {
        struct TestCurlEndpoint: Endpoint {
            struct Parameters: Encodable {
                let name: String
            }
            typealias Response = Void
            let parameters: Parameters
            let route = POST("curl")
        }
        let endpoint = TestCurlEndpoint(parameters: .init(name: "rickb"))
            .modify(.curl())
        
        let request = try await URLRequest(
            baseURL: testBaseURL,
            endpoint: endpoint
        )
        let expectedCurl = """
        curl -f -X POST --url 'https://www.rickb.com/curl' -H 'Content-Type: application/json' --data '{"name":"rickb"}'
        """
        #expect(request.curl() == expectedCurl)
    }

    @Test func curlGET() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.curl())

        let request = try await URLRequest(
            baseURL: testBaseURL,
            endpoint: endpoint
        )
        let expectedCurl = "curl -f -X GET --url 'https://www.rickb.com/curlGET()' "
        #expect(request.curl() == expectedCurl)
    }

    @Test func get() throws {
        let curl = "curl https://example.com/api"
        let request = try #require(URLRequest(curl: curl))
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://example.com/api")
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaderFields?.isEmpty == true)
    }

    @Test func post() throws {
        let curl = """
        curl -X POST "https://example.com/api" \
        -H 'Content-Type: application/json' \
        -H 'Content-Type: application/json' \
        --data '{\"name\":\"John\"}'
        """
        let request = try #require(URLRequest(curl: curl))
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://example.com/api")
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(String(data: request.httpBody ?? Data(), encoding: .utf8) == "{\"name\":\"John\"}")
    }

    @Test func headers() throws {
        let curl = """
        curl -X GET https://example.com \
        -H 'Accept: application/json' \
        -H 'Authorization: Bearer token123'
        """
        let request = try #require(URLRequest(curl: curl))
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?["Accept"] == "application/json")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer token123")
    }

    @Test func missinURL() {
        let curl = "curl -X POST -H 'Content-Type: application/json' --data '{\"test\":true}'"
        #expect(URLRequest(curl: curl) == nil)
    }

    @Test func rawData() throws {
        let curl = """
        curl -X PUT https://example.com/update \
        --data-raw 'update=true'
        """
        let request = try #require(URLRequest(curl: curl))
        #expect(request.httpMethod == "PUT")
        #expect(request.url?.absoluteString == "https://example.com/update")
        #expect(String(data: request.httpBody ?? Data(), encoding: .utf8) == "update=true")
    }
}

struct RequestHeader {

    @Test func mergeRemoveHeaders() async throws {
        try await TestEmptyEndpoint()
            .modify(.merge(headers: ["pageName": "original", "auth": "123", "remove": "me"]))
            .modify(.merge(headers: ["pageName": "home"]))
            .modify(.merge(headers: ["pageName": "dontChange"], uniquingKeysWith: { a, _ in a }))
            .modify(.remove(headers: ["remove"]))
            .requestMatches(
                headers: [
                    "pageName": "home", "auth": "123"
                ]
            )
    }

    @Test func urlRequestHeaders() async throws {
        let urlRequest = URLRequest(url: testBaseURL)
            .merge(headers: ["pageName": "original", "auth": "123", "remove": "me"])
            .merge(headers: ["pageName": "home"])
            .remove(headers: ["remove"])

        #expect(urlRequest.allHTTPHeaderFields == ["pageName": "home", "auth": "123"])
    }
}

struct RequestTimeout {

    @Test func timeout() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.timeout(120))

        let urlRequest = try await  URLRequest(baseURL: testBaseURL, endpoint: endpoint)

        #expect(urlRequest.timeoutInterval == 120)
    }
}

struct RequestURL {

    @Test func map() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.map { _ in
                URL(string: "https://example.com")!
            })

        let urlRequest = try await URLRequest(baseURL: testBaseURL, endpoint: endpoint)

        #expect(urlRequest.url == URL(string: "https://example.com"))
    }

    @Test func mapURL() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.mapURLComponents(host: "example.com", path: "/test"))

        let urlRequest = try await URLRequest(baseURL: testBaseURL, endpoint: endpoint)

        #expect (urlRequest.url == URL(string:"https://example.com/test"))
    }

    @Test func testMapURLComponents() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.map { _ in
                URLComponents(string: "https://example.com/test")!
            })

        let urlRequest = try await URLRequest(baseURL: testBaseURL, endpoint: endpoint)

        #expect (urlRequest.url == URL(string:"https://example.com/test"))
    }
}

struct ResponsePrint {

    @Test func printResponse() async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.printResponse())

        let dataProvider = TestDataProvider()

        try await dataProvider.request(endpoint)
    }
}

struct ResponseValidation {

    @Test(arguments: [true, false])
    func validateDecodableError(requireHttpError: Bool) async throws {
        struct CustomError: Error, Decodable {
            let errorCode: Int
        }

        let endpoint = TestEmptyEndpoint().modify(.validate(error: CustomError.self, requireHttpError: requireHttpError))
        var dataProvider = TestDataProvider(body: #"{"errorCode": 1}"#, statusCode: requireHttpError ? 400 : 200)
        try await dataProvider.testResponseValidation(endpoint) { (error: CustomError) in
            #expect(error.errorCode == 1)
        }
    }

    @Test(arguments: [true, false])
    func validateError(requireHttpError: Bool) async throws {
        struct CustomStringError: LocalizedError {
            let errorCode: Int

            struct Decoder: ResponseDecoder {
                func decode(response: URLResponse, data: Data) async throws -> CustomStringError? {
                    return if let errorString = String(data: data, encoding: .utf8),
                              let errorCode = Int(errorString) {
                        CustomStringError(errorCode: errorCode)
                    } else {
                        nil
                    }
                }
            }
        }

        let endpoint = TestEmptyEndpoint().modify(.validate(
            error: CustomStringError.self,
            decoder: CustomStringError.Decoder(),
            requireHttpError: requireHttpError
        ))
        var dataProvider = TestDataProvider(body: "1", statusCode: requireHttpError ? 400 : 200)
        try await dataProvider.testResponseValidation(endpoint) { (error: CustomStringError) in
            #expect(error.errorCode == 1)
        }
    }

    @Test func validateHTTP() async throws {
        let endpoint = TestEmptyEndpoint().modify(.validateHTTP())
        var dataProvider = TestDataProvider(statusCode: 400)
        try await dataProvider.testResponseValidation(endpoint) { (error: HTTPError) in
            #expect(error.response.httpStatusCode == 400)
        }
    }
}

extension TestDataProvider {

    mutating
    func testResponseValidation<T: Endpoint,U: Error>(
        _ endpoint: T,
        _ error: U.Type = U.self,
        expect: @escaping (U) -> Void
    ) async throws {
        do {
            _ = try await request(endpoint)
            Issue.record("Should have failed")
        } catch let error as U {
            expect(error)
        }

        body = Data()
        statusCode = 200
        _ = try await request(endpoint)
    }
}

