//
//  EndpointTests.swift
//
//
//  Created by rickb on 6/14/23.
//
//

import Foundation
import XCTest

final class EndpointTests: XCTestCase {

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
            matchingBody: #"{"blueGoldDress":"blue"}"#
        )
    }

    func testDataParameterEncoder() async throws {
        let upload = API.ImageUpload(parameters: "123".data(using: .utf8)!) // swiftlint:disable:this force_unwrap
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

        let badDataProvider = TestDataProvider(body: #"{"bad": "string"}"#)
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

    func testErrorValidator() async throws {
        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#)
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

        let stringErrorDataProvider = TestDataProvider(body: "An error!", statusCode: 400)
        do {
            try await stringErrorDataProvider.request(baseURL: API.baseURL, endpoint: track)
            XCTFail("Should have failed")
        } catch let error as StringError {
            XCTAssertEqual(error.localizedDescription, "An error!")
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
                .modify(headerModifier(["pageName": "original"]))
                .modify(headerModifier(["pageName": "home"]))
                .modify(validateHTTPModifier()),
            baseURL: API.baseURL,
            matchingHeaders: ["pageName": "home"]
        )

        try await endpointRequestMatches(
            track.modify {
                $0.add(headers: ["pageName": "home"])
            },
            baseURL: API.baseURL,
            matchingHeaders: ["pageName": "home"]
        )
    }

    func testModifiers() async throws {
        guard #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) else {
            throw XCTSkip("Unsupported iOS version")
        }
        let getStuff = API.GetStuff()
        let modifiedEndpoint = getStuff.modify(modifiers(for: getStuff))

        try await endpointRequestMatches(
            modifiedEndpoint,
            baseURL: API.baseURL,
            matchingHeaders: ["a": "b", "c": "d"]
        )
        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#)
        do {
            try await errorDataProvider.request(baseURL: API.baseURL, endpoint: modifiedEndpoint)
            XCTFail("Should have failed")
        } catch let error as API.CustomError {
            XCTAssertEqual(error.errorCode, 1)
        }
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func modifiers<T: APIEndpoint>(for endpoint: T) -> [any APIEndpointModifier<T.Parameters, T.Response>] {
        var modifiers = [any APIEndpointModifier<T.Parameters, T.Response>]()
        modifiers.append(headerModifier(["a": "b", "c": "d"]))

        if endpoint is CustomErrorProtocol {
            modifiers.append(APIEndpointResponseModifier {
                $0.validate(error: API.CustomError.self)
            })
        }
        return modifiers
    }

    func testTypeErasedModifiers() async throws {
        let getStuff = API.GetStuff()
        let modifiedEndpoint = getStuff.modify(typeErasedModifiers(for: getStuff))

        try await endpointRequestMatches(
            modifiedEndpoint,
            baseURL: API.baseURL,
            matchingHeaders: ["a": "b", "c": "d"]
        )
        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#)
        do {
            try await errorDataProvider.request(baseURL: API.baseURL, endpoint: modifiedEndpoint)
            XCTFail("Should have failed")
        } catch let error as API.CustomError {
            XCTAssertEqual(error.errorCode, 1)
        }
    }

    func typeErasedModifiers<T: APIEndpoint>(for endpoint: T) -> [AnyAPIEndpointModifier<T.Parameters, T.Response>] {
        var modifiers = [AnyAPIEndpointModifier<T.Parameters, T.Response>]()
        modifiers.append(headerModifier(["a": "b", "c": "d"]).any())

        if endpoint is CustomErrorProtocol {
            modifiers.append(APIEndpointResponseModifier {
                $0.validate(error: API.CustomError.self)
            }.any())
        }
        return modifiers
    }

    func testHTTPError() throws {
        let response = HTTPURLResponse(url: URL(string: "http://www.rickb.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!

        let error = HTTPError(data: Data(), response: response)
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.localizedDescription, "HTTP Error: 401")

        do {
            try throwIfHttpError(response: response, data: Data())
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 401)
        }

        let urlResponse = URLResponse(url: URL(string: "https://www.rickb.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertNil(urlResponse.httpStatusCode)
        XCTAssertFalse(urlResponse.isHttpError)
    }

    func testAnyAPIEndpointInit() {
        let endpoint = AnyAPIEndpoint(parameters: Data(), endpoint: GET("/hello"), parameterEncoder: DataParameterEncoder(), responseDecoder: EmptyResponseDecoder())

        XCTAssertEqual(endpoint.parameters, Data())
        XCTAssertEqual(endpoint.endpoint,  GET("/hello"))
        XCTAssert(endpoint.parameterEncoder is DataParameterEncoder)
        XCTAssert(endpoint.responseDecoder is EmptyResponseDecoder)
    }

    func testModifierClosureInitializer() async throws {
        let dataProvider = TestDataProvider(body: "123")
        let form = API.Form(parameters: .init(
            username: "traveler123", password: "test123"
        ))

        let parameterModifier = APIEndpointParameterModifier<API.Form.Parameters, API.Form.Response> { encoder, parameters, request in
            request
        }
        let responseModifier = APIEndpointResponseModifier<API.Form.Parameters, API.Form.Response> { decoder, response, data in
            try await decoder.decode(response: response, data: data)
        }

        var modified = form.modify(parameterModifier)
        modified = modified.modify(responseModifier)

        let result = try await dataProvider.request(baseURL: API.baseURL, endpoint: modified)
        XCTAssertEqual(result, "123")
    }
}

func endpointRequestMatches<T: APIEndpoint>(_ endpoint: T, baseURL: URL, matchingURL url: String? = nil, matchingBody httpBody: String? = nil, matchingHeaders headers: [String: String]? = nil) async throws {
    let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
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

func endpointRequestMatches<T: APIEndpoint>(_ endpoint: T, baseURL: URL, matchingURL url: String? = nil, matchingHeaders headers: [String: String]? = nil, decoder: JSONDecoder) async throws where T.Parameters: Codable & Equatable {

    let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
    if let url {
        XCTAssertEqual(request.url, URL(string: url)!)  // swiftlint:disable:this force_unwrap
    }

    let parameters = try decoder.decode(T.Parameters.self, from: request.httpBody!)
    XCTAssertEqual(endpoint.parameters, parameters)

    if let headers {
        let keys = headers.keys
        XCTAssertEqual(headers, request.allHTTPHeaderFields?.filter { keys.contains($0.key) })
    }

    XCTAssertEqual(request.httpMethod, endpoint.endpoint.method.rawValue)
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
        (body, HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "1.1", headerFields: nil)!) // swiftlint:disable:this force_unwrap
    }
}

protocol CustomErrorProtocol {
}

enum API {
    struct Login: APIEndpoint {
        struct Parameters: Codable, Equatable {
            let username: String
            let password: String
        }

        struct Response: Decodable, Equatable {
            let accessToken: String
            let refreshToken: String
        }

        let endpoint = POST("/login")
        let parameters: Parameters
    }

    struct Track: APIEndpoint {
        struct Parameters: Encodable {
            let action: String
        }
        typealias Response = Void

        let endpoint = GET("/track")
        let parameters: Parameters

        var responseDecoder: any ResponseDecoder<Void> {
            EmptyResponseDecoder()
                .validateHTTP()
                .validate(error: CustomError.self)
        }
    }

    struct CustomError: Error, Decodable {
        let errorCode: Int
    }

    struct Form: APIEndpoint {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }
        typealias Response = String

        let endpoint = POST("/form")
        let parameters: Parameters

        var parameterEncoder: any ParameterEncoder<Parameters> {
            FormParameterEncoder()
        }
    }

    struct Poll: APIEndpoint {
        typealias Parameters = [String: Any]
        typealias Response = [String: Int]

        let pollId: String
        var endpoint: Endpoint { .init(.post, "/poll/\(pollId)") }
        let parameters: Parameters

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

        let endpoint = POST("/upload")
        let parameters: Parameters
    }

    struct ImageDownload: APIEndpoint {
        typealias Response = Data

        let endpoint = GET("/download")
    }

    struct GetStuff: APIEndpoint, CustomErrorProtocol {
        typealias Parameters = Void
        typealias Response = Void

        let endpoint = GET("/getstuff")
    }

    static let baseURL = URL(string: "https://www.rickb.com")!

    static let headers = ["pageName": "home"]
}
