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
    )
    func cachePolicy(cachePolicy: URLRequest.CachePolicy) async throws {
        let endpoint = TestEmptyEndpoint()
            .modify(.cachePolicy(cachePolicy))

        let request = try await URLRequest(baseURL: testBaseURL, endpoint: endpoint)
        #expect(request.cachePolicy == cachePolicy)
    }
}

struct RequestContentType {

    @Test func contentType() async throws {
        try await TestEmptyEndpoint()
            .modify(.contentType("application/json"))
            .requestMatches(
                headers: ["Content-Type": "application/json"]
            )
    }
}

struct RequestcURL {

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

}

struct RequestURL {

}

struct ResponsePrint {

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

