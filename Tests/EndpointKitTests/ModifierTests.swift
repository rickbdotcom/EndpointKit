//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import Testing
@testable import EndpointKit
#if os(iOS)
import UIKit
#endif

struct RequestAuthorization {

    @Test func bearer() async throws {
        try await TestModifiedEndpoint()
            .modify(.authorize(with: BearerAuthorization(userName: "rickb", password: "test", key: "key")))
            .requestMatches(
                headers: ["key": "Bearer cmlja2I6dGVzdA=="]
            )

        try await TestModifiedEndpoint()
            .modify(.authorize(with: BearerAuthorization(userName: "rickb", password: "test")))
            .requestMatches(
                headers: ["Authorization": "Bearer cmlja2I6dGVzdA=="]
            )

        try await TestModifiedEndpoint()
            .modify(.authorize(with: BearerAuthorization(authToken: "cmlja2I6dGVzdA==")))
            .requestMatches(
                headers: ["Authorization": "Bearer cmlja2I6dGVzdA=="]
            )
    }

    @Test func basic() async throws {
        try await TestModifiedEndpoint()
            .modify(.authorize(with: BasicAuthorization(authToken: "token", key: "key")))
            .requestMatches(
                headers: ["key": "Basic token"]
            )

        try await TestModifiedEndpoint()
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
        let endpoint = TestModifiedEndpoint()
            .modify(.cachePolicy(cachePolicy))

        let request = try await URLRequest(baseURL: .test, endpoint: endpoint)
        #expect(request.cachePolicy == cachePolicy)
    }
}

struct RequestContentType {

    @Test func contentType() async throws {
        try await TestModifiedEndpoint()
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
            baseURL: .test,
            endpoint: endpoint
        )
        let expectedCurl = """
        curl -f -X POST --url 'https://www.rickb.com/curl' -H 'Content-Type: application/json' --data '{"name":"rickb"}'
        """
        #expect(request.curl() == expectedCurl)
    }

    @Test func curlGET() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.curl())

        let request = try await URLRequest(
            baseURL: .test,
            endpoint: endpoint
        )
        let expectedCurl = "curl -f -X GET --url 'https://www.rickb.com/modify-me' "
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

    @Test func missingURL() {
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

    @Test func binary() async throws {
        let base64Image = "/9j/4QDKRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEAAAEaAAUAAAABAAAAVgEbAAUAAAABAAAAXgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAZgAAAAAAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAACCgAwAEAAAAAQAAABWkBgADAAAAAQAAAAAAAAAAAAD/2wCEAAEBAQEBAQIBAQIDAgICAwQDAwMDBAUEBAQEBAUGBQUFBQUFBgYGBgYGBgYHBwcHBwcICAgICAkJCQkJCQkJCQkBAQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCf/dAAQAAf/AABEIAAsAEAMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOpuP+C7uheNfhrpnhaf4PW1neDMVvFdGSAzKfvELLDG4Axg7hkHAxyK/NX4+/8ABUTXLia4uH+HHhu2ggSQMsF1dz3DPhPKX5ooVXAyrjLYwACK/Mjwj+0T8btL09rG28SXjQxXCxKkzCYBCORiQNXUeMPi18QdSsPO1DUPOYSMuWiiPAfA/g9K/hzLc0znLsXyxa5G/wCeV/8A0nsfX5lnsMXSvNK6/uo//9k="

        let expectedCurl = #"curl -f -X POST --url 'https://www.rickb.com/image' -H 'Content-Type: application/octet-stream' --data-binary $'\xFF\xD8\xFF\xE1\x00\xCA\x45\x78\x69\x66\x00\x00\x4D\x4D\x00\x2A\x00\x00\x00\x08\x00\x06\x01\x12\x00\x03\x00\x00\x00\x01\x00\x01\x00\x00\x01\x1A\x00\x05\x00\x00\x00\x01\x00\x00\x00\x56\x01\x1B\x00\x05\x00\x00\x00\x01\x00\x00\x00\x5E\x01\x28\x00\x03\x00\x00\x00\x01\x00\x02\x00\x00\x02\x13\x00\x03\x00\x00\x00\x01\x00\x01\x00\x00\x87\x69\x00\x04\x00\x00\x00\x01\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x48\x00\x00\x00\x01\x00\x00\x00\x48\x00\x00\x00\x01\x00\x07\x90\x00\x00\x07\x00\x00\x00\x04\x30\x32\x32\x31\x91\x01\x00\x07\x00\x00\x00\x04\x01\x02\x03\x00\xA0\x00\x00\x07\x00\x00\x00\x04\x30\x31\x30\x30\xA0\x01\x00\x03\x00\x00\x00\x01\x00\x01\x00\x00\xA0\x02\x00\x04\x00\x00\x00\x01\x00\x00\x00\x20\xA0\x03\x00\x04\x00\x00\x00\x01\x00\x00\x00\x15\xA4\x06\x00\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xDB\x00\x84\x00\x01\x01\x01\x01\x01\x01\x02\x01\x01\x02\x03\x02\x02\x02\x03\x04\x03\x03\x03\x03\x04\x05\x04\x04\x04\x04\x04\x05\x06\x05\x05\x05\x05\x05\x05\x06\x06\x06\x06\x06\x06\x06\x06\x07\x07\x07\x07\x07\x07\x08\x08\x08\x08\x08\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x01\x01\x01\x01\x02\x02\x02\x04\x02\x02\x04\x09\x06\x05\x06\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\xFF\xDD\x00\x04\x00\x01\xFF\xC0\x00\x11\x08\x00\x0B\x00\x10\x03\x01\x22\x00\x02\x11\x01\x03\x11\x01\xFF\xC4\x01\xA2\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x10\x00\x02\x01\x03\x03\x02\x04\x03\x05\x05\x04\x04\x00\x00\x01\x7D\x01\x02\x03\x00\x04\x11\x05\x12\x21\x31\x41\x06\x13\x51\x61\x07\x22\x71\x14\x32\x81\x91\xA1\x08\x23\x42\xB1\xC1\x15\x52\xD1\xF0\x24\x33\x62\x72\x82\x09\x0A\x16\x17\x18\x19\x1A\x25\x26\x27\x28\x29\x2A\x34\x35\x36\x37\x38\x39\x3A\x43\x44\x45\x46\x47\x48\x49\x4A\x53\x54\x55\x56\x57\x58\x59\x5A\x63\x64\x65\x66\x67\x68\x69\x6A\x73\x74\x75\x76\x77\x78\x79\x7A\x83\x84\x85\x86\x87\x88\x89\x8A\x92\x93\x94\x95\x96\x97\x98\x99\x9A\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\x01\x00\x03\x01\x01\x01\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x11\x00\x02\x01\x02\x04\x04\x03\x04\x07\x05\x04\x04\x00\x01\x02\x77\x00\x01\x02\x03\x11\x04\x05\x21\x31\x06\x12\x41\x51\x07\x61\x71\x13\x22\x32\x81\x08\x14\x42\x91\xA1\xB1\xC1\x09\x23\x33\x52\xF0\x15\x62\x72\xD1\x0A\x16\x24\x34\xE1\x25\xF1\x17\x18\x19\x1A\x26\x27\x28\x29\x2A\x35\x36\x37\x38\x39\x3A\x43\x44\x45\x46\x47\x48\x49\x4A\x53\x54\x55\x56\x57\x58\x59\x5A\x63\x64\x65\x66\x67\x68\x69\x6A\x73\x74\x75\x76\x77\x78\x79\x7A\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x92\x93\x94\x95\x96\x97\x98\x99\x9A\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFF\xDA\x00\x0C\x03\x01\x00\x02\x11\x03\x11\x00\x3F\x00\xEA\x6E\x3F\xE0\xBB\xBA\x17\x8D\x7E\x1A\xE9\x9E\x16\x9F\xE0\xF5\xB5\x9D\xE0\xCC\x56\xF1\x5D\x19\x20\x33\x29\xFB\xC4\x2C\xB0\xC6\xE0\x0C\x60\xEE\x19\x07\x03\x1C\x8A\xFC\xD5\xF8\xFB\xFF\x00\x05\x44\xD7\x2E\x26\xB8\xB8\x7F\x87\x1E\x1B\xB6\x82\x04\x90\x32\xC1\x75\x77\x3D\xC3\x3E\x13\xCA\x5F\x9A\x28\x55\x70\x32\xAE\x32\xD8\xC0\x00\x8A\xFC\xC8\xF0\x8F\xED\x13\xF1\xBB\x4B\xD3\xDA\xC6\xDB\xC4\x97\x8D\x0C\x57\x0B\x12\xA4\xCC\x26\x01\x08\xE4\x62\x40\xD5\xD4\x78\xC3\xE2\xD7\xC4\x1D\x4A\xC3\xCE\xD4\x35\x0F\x39\x84\x8C\xB9\x68\xA2\x3C\x07\xC0\xFE\x0F\x4A\xFE\x1C\xCB\x73\x4C\xE7\x2E\xC5\xF2\xC5\xAE\x46\xFF\x00\x9E\x57\xFF\x00\xD2\x7B\x1F\x5F\x99\x67\xB0\xC5\xD2\xBC\xD2\xBA\xFE\xEA\x3F\xFF\xD9'"#

        struct ImageUpload: Endpoint {
            typealias Parameters = Data
            typealias Response = Void
            let parameters: Data
            let route = POST("/image")
        }
        let data = try #require(Data(base64Encoded: base64Image))
        let endpoint = ImageUpload(parameters: data)
            .modify(.curl())

        let request = try await URLRequest(
            baseURL: .test,
            endpoint: endpoint
        )
        #expect(request.curl() == expectedCurl)
/* fixme
#if os(iOS)
        let binaryRequest = try #require(URLRequest(curl: request.curl()))
        let binaryData = try #require(binaryRequest.httpBody)
        let image = try #require(UIImage(data: binaryData))
        #expect(image.size == .init(width: 16, height: 11))
#endif*/
    }
}

struct RequestHeader {

    @Test func mergeRemoveHeaders() async throws {
        try await TestModifiedEndpoint()
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
        let urlRequest = URLRequest.test
            .merge(headers: ["pageName": "original", "auth": "123", "remove": "me"])
            .merge(headers: ["pageName": "home"])
            .remove(headers: ["remove"])

        #expect(urlRequest.allHTTPHeaderFields == ["pageName": "home", "auth": "123"])
    }
}

struct RequestTimeout {

    @Test func timeout() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.timeout(120))

        let urlRequest = try await  URLRequest(baseURL: .test, endpoint: endpoint)

        #expect(urlRequest.timeoutInterval == 120)
    }
}

struct RequestURL {

    @Test func map() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.map { _ in
                URL(string: "https://example.com")!
            })

        let urlRequest = try await URLRequest(baseURL: .test, endpoint: endpoint)

        #expect(urlRequest.url == URL(string: "https://example.com"))
    }

    @Test func mapURL() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.mapURLComponents(host: "example.com", path: "/test"))

        let urlRequest = try await URLRequest(baseURL: .test, endpoint: endpoint)

        #expect (urlRequest.url == URL(string:"https://example.com/test"))
    }

    @Test func testMapURLComponents() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.map { _ in
                URLComponents(string: "https://example.com/test")!
            })

        let urlRequest = try await URLRequest(baseURL: .test, endpoint: endpoint)

        #expect (urlRequest.url == URL(string:"https://example.com/test"))
    }
}

struct ResponsePrint {

    @Test func printResponse() async throws {
        let endpoint = TestModifiedEndpoint()
            .modify(.printResponse())

        let dataProvider = TestClient()

        try await dataProvider.request(endpoint)
    }
}

struct ResponseValidation {

    @Test(arguments: [true, false])
    func validateDecodableError(requireHttpError: Bool) async throws {
        struct CustomError: Error, Decodable {
            let errorCode: Int
        }

        let endpoint = TestModifiedEndpoint().modify(.validate(error: CustomError.self, requireHttpError: requireHttpError))
        var dataProvider = TestClient(body: #"{"errorCode": 1}"#, statusCode: requireHttpError ? 400 : 200)
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

        let endpoint = TestModifiedEndpoint().modify(.validate(
            error: CustomStringError.self,
            decoder: CustomStringError.Decoder(),
            requireHttpError: requireHttpError
        ))
        var dataProvider = TestClient(body: "1", statusCode: requireHttpError ? 400 : 200)
        try await dataProvider.testResponseValidation(endpoint) { (error: CustomStringError) in
            #expect(error.errorCode == 1)
        }
    }

    @Test func validateHTTP() async throws {
        let endpoint = TestModifiedEndpoint().modify(.validateHTTP())
        var dataProvider = TestClient(statusCode: 400)
        try await dataProvider.testResponseValidation(endpoint) { (error: HTTPError) in
            #expect(error.response.httpStatusCode == 400)
        }
    }
}

extension TestClient {

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

private struct TestModifiedEndpoint: Endpoint {
    typealias Response = Void
    let route = GET("/modify-me")
}

