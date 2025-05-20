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

final class ServiceEndpointTests: XCTestCase {

    func testAnyEndpointInit() {
        let endpoint = AnyEndpoint(
            parameters: Data(),
            route: GET("hello"),
            parameterEncoder: DataParameterEncoder(),
            responseDecoder: EmptyResponseDecoder()
        )

        XCTAssertEqual(endpoint.parameters, Data())
        
// fixme rickb        XCTAssertEqual(endpoint.method, .get)
// fixme rickb        XCTAssertEqual(endpoint.path, "hello")
        XCTAssert(endpoint.requestEncoder is DataParameterEncoder)
        XCTAssert(endpoint.responseDecoder is EmptyResponseDecoder)
    }

    func testHTTPError() throws {
        let url = try XCTUnwrap(URL(string: "http://www.rickb.com"))
        let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil))

        let error = HTTPError(data: Data(), response: response)
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.localizedDescription, "HTTP Error: 401")

        do {
            try HTTPError.throwIfError(response: response, data: Data())
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 401)
        }

        let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertTrue(urlResponse.isHttpError)
    }

}
*/
