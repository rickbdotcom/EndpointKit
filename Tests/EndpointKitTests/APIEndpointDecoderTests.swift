//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import XCTest
@testable import EndpointKit

final class ServiceEndpointDecoderTests: XCTestCase {

    func testJSONResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: #"{"accessToken": "123", "refreshToken": "456"}"#)
        let login = API.Login(parameters: .init(
            username: "traveler123", password: "test123"
        ))
        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: login)
        XCTAssertEqual(result, API.Login.Response(accessToken: "123", refreshToken: "456"))
    }

    func testDictionaryResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: #"{"blue": 10, "gold": 5}"#)
        let poll = API.Poll(pollId: "1", parameters: ["blueGoldDress": "blue"])
        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: poll)
        XCTAssertEqual(result, ["blue": 10, "gold": 5])
    }

    func testBadDataProvider() async throws {
        let badDataProvider = TestDataProvider(body: #"{"bad": "string"}"#)
        let poll = API.Poll(pollId: "1", parameters: ["blueGoldDress": "blue"])
        do {
            _ = try await badDataProvider.request(baseURL: API.baseURL, endpoint: poll)
        } catch {
            XCTAssertTrue(error is SerializedJSONResponseDecoder<API.Poll.Response>.DecodeError)
        }
    }

    func testDataResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let imageDownload = API.ImageDownload()
        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: imageDownload)
        XCTAssertEqual("123", String(data: result, encoding: .utf8))
    }

    func testStringResponseDecoder() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let form = API.Form(parameters: .init(
            username: "traveler123", password: "test123"
        ))
        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: form)
        XCTAssertEqual("123", result)

        let badDataProvider = TestDataProvider(body: Data([0b01010101, 0b11110000, 0b00110011]))
        do {
            _ = try await badDataProvider.request(baseURL: API.baseURL, endpoint: form)
        } catch {
            XCTAssertTrue(error is StringResponseDecoder.DecodeError)
        }
    }

    func testVoidResponse() async throws {
        let dataProvider = TestDataProvider()
        let track = API.Track(parameters: .init(
            action: "login"
        ))
        try await dataProvider.request(baseURL: API.baseURL, endpoint: track)
    }
}
