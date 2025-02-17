//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import XCTest
@testable import EndpointKit

final class ServiceEndpointModifierTests: XCTestCase {

    func testErrorValidator() async throws {
        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#, statusCode: 400)
        let track = API.Track(parameters: .init(
            action: "login"
        ))
        do {
            try await errorDataProvider.request(baseURL: API.baseURL, endpoint: track)
            XCTFail("Should have failed")
        } catch let error as API.CustomError {
            XCTAssertEqual(error.errorCode, 1)
        }

        let emptyDataProvider = TestDataProvider()
        try await emptyDataProvider.request(baseURL: API.baseURL, endpoint: track)
    }

    func testModifyErrorValidator() async throws {
        struct StringError: LocalizedError {
            let errorDescription: String?
        }

        struct StringErrorDecoder: ResponseDecoder {
            func decode(response: URLResponse, data: Data) async throws -> StringError? {
                if response.isHttpError {
                    return StringError(errorDescription: String(data: data, encoding: .utf8))
                } else {
                    return nil
                }
            }
        }

        let track = API.Track(parameters: .init(
            action: "login"
        )).modify {
            $0.validate(error: StringError.self, decoder: StringErrorDecoder())
        }

        let stringErrorDataProvider = TestDataProvider(body: "An error", statusCode: 400)
        do {
            try await stringErrorDataProvider.request(baseURL: API.baseURL, endpoint: track)
            XCTFail("Should have failed")
        } catch let error as StringError {
            XCTAssertEqual(error.localizedDescription, "An error")
        }

        let dataProvider = TestDataProvider(body: "")
        try await dataProvider.request(baseURL: API.baseURL, endpoint: track)
    }

    func testHeaders() async throws {
        let track = API.Track(parameters: .init(
            action: "login"
        ))
        try await endpointRequestMatches(
            track
                .modify(.merge(headers: ["pageName": "original", "remove": "me"]))
                .modify(.merge(headers: ["pageName": "home"]))
                .modify(.validateHTTP())
                .modify(.remove(headers: ["me"]))
                .modify(.contentType("application/vnd.aa.mobile.app+json;version=50.0")),
            baseURL: API.baseURL,
            matchingHeaders: [
                "pageName": "home",
                "Content-Type": "application/vnd.aa.mobile.app+json;version=50.0"
            ]
        )

        try await endpointRequestMatches(
            track
                .modify {
                    $0.merge(headers: ["pageName": "home", "remove": "me", "override": "original"])
                }
                .modify {
                    $0.remove(headers: ["remove"])
                }
                .modify {
                    $0.merge(headers: ["override": "new"]) { a, b in b }
                },
            baseURL: API.baseURL,
            matchingHeaders: ["pageName": "home", "override": "original"]
        )
    }

    func testModifiers() async throws {
        let getStuff = API.GetStuff()
        let modifiedEndpoint = getStuff.modify(modifiers(for: getStuff))

        try await endpointRequestMatches(
            modifiedEndpoint,
            baseURL: API.baseURL,
            matchingHeaders: ["a": "b", "c": "d"]
        )
        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#, statusCode: 400)
        do {
            try await errorDataProvider.request(baseURL: API.baseURL, endpoint: modifiedEndpoint)
            XCTFail("Should have failed")
        } catch let error as API.CustomError {
            XCTAssertEqual(error.errorCode, 1)
        }
    }

    func modifiers<T: Endpoint>(for endpoint: T) -> [AnyEndpointModifier<T.Parameters, T.Response>] {
        var modifiers = [AnyEndpointModifier<T.Parameters, T.Response>]()
        modifiers.append(.merge(headers: ["a": "b", "c": "d"]).any())

        if endpoint is CustomErrorProtocol {
            modifiers.append(ResponseModifier {
                $0.validate(error: API.CustomError.self)
            }.any())
        }
        return modifiers
    }
    
    func testModifierClosureInitializer() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let form = API.Form(parameters: .init(
            username: "traveler123", password: "test123"
        ))

        let parameterModifier = RequestModifier<API.Form.Parameters, API.Form.Response> { encoder, parameters, request in
            request
        }
        let responseModifier = ResponseModifier<API.Form.Parameters, API.Form.Response> { decoder, response, data in
            try await decoder.decode(response: response, data: data)
        }

        var modified = form.modify(parameterModifier)
        modified = modified.modify(responseModifier)

        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: modified)
        XCTAssertEqual(result, "123")
    }
}
