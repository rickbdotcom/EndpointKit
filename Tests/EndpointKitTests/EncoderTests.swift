//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//
/*
import Foundation
import XCTest
@testable import EndpointKit

final class ServiceEndpointEncoderTests: XCTestCase {

    func testJSONParameterEncoder() async throws {
        let login = API.Login(parameters: .init(
            username: "traveler123", password: "test123"
        ))

        try await endpointRequestMatches(
            login,
            baseURL: API.baseURL,
            matchingURL: "https://www.rickb.com/login",
            decoder: JSONDecoder()
        )

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting.formUnion(.prettyPrinted)
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let customEncoder = JSONEncodableParameterEncoder<API.Login.Parameters>(encoder: jsonEncoder)

        XCTAssertEqual(customEncoder.encoder.outputFormatting, [.sortedKeys, .prettyPrinted])
        guard case .convertToSnakeCase = customEncoder.encoder.keyEncodingStrategy else {
            XCTFail("keyEncoding doesn't match")
            return
        }

        let encoder = JSONEncodableParameterEncoder<API.Login.Parameters>()

        XCTAssertEqual(encoder.encoder.outputFormatting, .sortedKeys)
    }

    func testURLParameterEncoder() async throws {
        let track = API.Track(parameters: .init(
            action: "login"
        ))
        try await endpointRequestMatches(
            track,
            baseURL: API.baseURL,
            matchingURL: "https://www.rickb.com/track?action=login"
        )
    }

    func testFormParameterEncoder() async throws {
        let form = API.Form(parameters: .init(
            username: "traveler123", password: "test123"
        ))
        try await endpointRequestMatches(
            form,
            baseURL: API.baseURL,
            matchingURL: "https://www.rickb.com/form",
            matchingBody: "password=test123&username=traveler123"
        )
    }

    func testDictionaryParameterEncoder() async throws {
        let poll = API.Poll(pollId: "1", parameters: ["blueGoldDress": "blue"])
        try await endpointRequestMatches(
            poll,
            baseURL: API.baseURL,
            matchingURL: "https://www.rickb.com/poll/1",
            matchingBody: #"{"blueGoldDress":"blue"}"#,
            matchingHeaders: [
                "Content-Type": "application/vnd.aa.mobile.app+json;version=50.0"
            ]
        )
    }

    func testDataParameterEncoder() async throws {
        let upload = try API.ImageUpload(parameters: XCTUnwrap("123".data(using: .utf8)))
        try await endpointRequestMatches(
            upload,
            baseURL: API.baseURL,
            matchingURL: "https://www.rickb.com/upload",
            matchingBody: "123"
        )
    }

    func testVoidParameters() async throws {
        let imageDownload = API.ImageDownload()
        let request = try await URLRequest(baseURL: API.baseURL, endpoint: imageDownload)
        XCTAssertEqual(request.httpBody, nil)
    }
}
*/
