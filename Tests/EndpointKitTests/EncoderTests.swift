//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Testing
import Foundation
@testable import EndpointKit

struct AnyRequestEncoderTests {

    @Test func encode() async throws {
        let randomURL = try #require(URL(string: "https://\(UUID().uuidString)"))

        let encoder = AnyRequestEncoder<Int> { parameters, request in
            #expect(parameters == 1)
            #expect(request == .test)
            return URLRequest(url: randomURL)
        }
        let request = try await encoder.encode(1, into: .test)
        #expect(request.url == randomURL)
    }

    @Test func encodeError() async throws {
        struct EncodeError: Error {
        }
        let encoder = AnyRequestEncoder<Void> { _, _ in
            throw EncodeError()
        }
        do {
            _ = try await encoder.encode((), into: .test)
            Issue.record("Should have failed")
        } catch let error as EncodeError {
            print(error)
        }
    }
}

struct DataParameterEncoderTests {

    @Test func encode() throws {
        let data = Data(repeating: 6, count: 3)
        let encoder = DataParameterEncoder()
        let request = try encoder.encode(data, into: .test)
        #expect(request.url == .test)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/octet-stream")
        #expect(request.httpBody == data)
    }
}

struct EmptyParameterEncoderTests {

    @Test func encode() throws {
        let encoder = EmptyParameterEncoder()
        let request = URLRequest.test
        let newRequest = try encoder.encode((), into: .test)
        #expect(request.url == newRequest.url)
        #expect(request.allHTTPHeaderFields == newRequest.allHTTPHeaderFields)
        #expect(request.cachePolicy == newRequest.cachePolicy)
        #expect(request.timeoutInterval == newRequest.timeoutInterval)
        #expect(request.httpMethod == newRequest.httpMethod)
        #expect(request.httpBody == newRequest.httpBody)
    }
}

struct FormParameterEncoderTests {

    struct Parameters: Encodable {
        let userName: String
        let password: String
        let isElite: Bool
        let miles: Int?
        let date: Date?
    }

    @Test func defaultEncoder() throws {
        let encoder = FormParameterEncoder<Parameters>()
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: 100, date: nil),
            into: .test
        )
        #expect(request.url == .test)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/x-www-form-urlencoded")
        #expect(request.body == "isElite=1&miles=100&password=password&userName=rickb")
    }

    @Test func customEncoder() throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder.dateEncodingStrategy = .iso8601

        let encoder = FormParameterEncoder<Parameters>(encoder: jsonEncoder)
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: nil, date: .test),
            into: .test
        )
        #expect(request.url == .test)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/x-www-form-urlencoded")
        #expect(request.body == "date=1970-01-01T00:00:00Z&is_elite=1&password=password&user_name=rickb")
    }
}

struct JSONEncodableParameterEncoderTests {

    struct Parameters: Encodable {
        let userName: String
        let password: String
        let isElite: Bool
        let miles: Int?
        let date: Date?
    }

    @Test func defaultEncode() throws {
        let encoder = JSONEncodableParameterEncoder<Parameters>()
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: 100, date: nil),
            into: URLRequest.test
        )
        #expect(request.url == .test)
        print(request.body!)
        #expect(request.body == #"{"isElite":true,"miles":100,"password":"password","userName":"rickb"}"#)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/json")
    }

    @Test func customEncode() async throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder.dateEncodingStrategy = .iso8601

        let encoder = JSONEncodableParameterEncoder<Parameters>(encoder: jsonEncoder)
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: nil, date: .test),
            into: .test
        )

        #expect(request.url == .test)
        #expect(request.body == #"{"date":"1970-01-01T00:00:00Z","is_elite":true,"password":"password","user_name":"rickb"}"#)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/json")
    }
}

struct JSONSerializationParameterEncoderTests {

    @Test func encode() throws {
        let dictionary: [String: Any] = [
            "username": "rickb",
            "password": "password",
            "isElite": true,
            "miles": 100
        ]
        let encoder = JSONSerializationParameterEncoder<[String: Any]>()
        let request = try encoder.encode(dictionary, into: .test)

        #expect(request.url == .test)
        #expect(request.body == #"{"isElite":true,"miles":100,"password":"password","username":"rickb"}"#)
        #expect(request.value(forHTTPHeaderField: "Content-type") == "application/json")
    }

    @Test func error() throws {
        let dictionary: [String: Any] = [
            "date": Date()
        ]

        do {
            let encoder = JSONSerializationParameterEncoder<[String: Any]>()
            _ = try encoder.encode(dictionary, into: .test)
            Issue.record("Should have failed")
        } catch let error as JSONSerializationParameterEncoder<[String: Any]>.EncodeError {
            print(error)
        }
    }
}

struct URLParameterEncoderTests {
    struct Parameters: Encodable {
        let userName: String
        let password: String
        let isElite: Bool
        let miles: Int?
        let date: Date?
    }

    @Test func defaultEncode() throws {
        let encoder = URLParameterEncoder<Parameters>()
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: 100, date: nil),
            into: .test
        )

        #expect(request.url?.absoluteString == "https://www.rickb.com?isElite=1&miles=100&password=password&userName=rickb")
        #expect(request.httpBody == nil)
    }

    @Test func customEncode() async throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder.dateEncodingStrategy = .iso8601

        let encoder = URLParameterEncoder<Parameters>(encoder: jsonEncoder)
        let request = try encoder.encode(
            Parameters(userName: "rickb", password: "password", isElite: true, miles: nil, date: .test),
            into: .test
        )
        #expect(request.url?.absoluteString == "https://www.rickb.com?date=1970-01-01T00:00:00Z&is_elite=1&password=password&user_name=rickb")
        #expect(request.httpBody == nil)
    }
}
