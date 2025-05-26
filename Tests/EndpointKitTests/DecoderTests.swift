//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Testing
import Foundation
@testable import EndpointKit

struct AnyResponseDecoderTests {

    @Test func decode() async throws {
        let testData = Data([1, 2, 3])
        let testResponse = URLResponse()

        let decoder = AnyResponseDecoder<Int> { response, data in
            #expect(response == testResponse)
            #expect(data == testData)
            return 1
        }

        let response = try await decoder.decode(response: testResponse, data: testData)
        #expect(response == 1)
    }
}

struct DataResponseDecoderTests {

    @Test func decode() throws {
        let data = Data()
        let decoder = DataResponseDecoder()
        let response = try decoder.decode(response: .init(), data: data)
        #expect(response == data)
    }
}

struct EmptyResponseDecoderTests {

    @Test func decode() throws {
        let decoder = EmptyResponseDecoder()
        try decoder.decode(response: URLResponse(), data: Data())
    }
}

struct JSONDecodableResponseDecoderTests {

    struct Response: Decodable, Equatable {
        let firstName: String
        let isElite: Bool
        let miles: Int?
        let date: Date?
    }

    @Test func defaultDecode() throws {
        let data = Data("""
            {
                "firstName": "Rick",
                "isElite": true,
                "miles": 100
            }
            """.utf8)
        let decoder = JSONDecodableResponseDecoder<Response>()
        let response = try decoder.decode(response: .init(), data: data)
        #expect(response == Response(firstName: "Rick", isElite: true, miles: 100, date: nil))
    }

    @Test func customDecode() throws {
        let data = Data("""
            {
                "first_name": "Rick",
                "is_elite": true,
                "miles": 100,
                "date" : "1970-01-01T00:00:00Z"
            }
            """.utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
        let decoder = JSONDecodableResponseDecoder<Response>(decoder: jsonDecoder)
        let response = try decoder.decode(response: .init(), data: data)
        #expect(response == Response(firstName: "Rick", isElite: true, miles: 100, date: .test))
    }

    static let badJSON = [
            """
            {
                "firstName": "Rick
            """,
            """
            {
                "firstName": "Rick"
            }
            """,
            """
            {
                "firstName": "Rick",
                "isElite": true,
                "miles": "100"
            }
            """
    ]

    @Test(arguments: badJSON)
    func error(json: String) throws {
        let data = Data(json.utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
        let decoder = JSONDecodableResponseDecoder<Response>(decoder: jsonDecoder)
        do {
            _ = try decoder.decode(response: .init(), data: data)
            Issue.record("Should have failed")
        } catch {
            print(error)
        }
    }
}

struct JSONSerializationResponseDecoderTests {

    @Test func decode() throws {
        let data = Data("""
            {
                "firstName": "Rick",
                "isElite": true,
                "miles": 100
            }
            """.utf8)
        let expectedResponse: [String: Any] = [
            "firstName": "Rick",
            "isElite": true,
            "miles": 100
        ]
        let decoder = JSONSerializationResponseDecoder<[String: Any]>()
        let response = try decoder.decode(response: .init(), data: data)
        #expect(NSDictionary(dictionary: response) == NSDictionary(dictionary: expectedResponse))
    }

    @Test func error() throws {
        let data = Data(#"{"name": "Rick"}"#.utf8)
        let decoder = JSONSerializationResponseDecoder<Date>()
        do {
            _ = try decoder.decode(response: .init(), data: data)
        } catch {
            print(error)
        }
    }
}

struct StringResponseDecoderTests {

    @Test(arguments: [String.Encoding.utf8, .isoLatin1, .ascii])
    func decode(encoding: String.Encoding) throws {
        let string = "hello"
        let data = try #require(string.data(using: encoding))

        let decoder = StringResponseDecoder()
        let responseString = try decoder.decode(response: .init(), data: data)
        #expect(string == responseString)
    }

    @Test func prettyifyJSON() throws {
        let string = #"{"name":"Rick"}"#
        let prettyString = #"""
            {
              "name" : "Rick"
            }
            """#
        let data = Data(string.utf8)

        let decoder = StringResponseDecoder(prettyifyJSON: true)
        let responseString = try decoder.decode(response: .init(), data: data)

        #expect(responseString == prettyString)
    }

    @Test func decodeError() throws {
        let data = Data([0xef])
        let decoder = StringResponseDecoder(encoding: .ascii)
        do {
            _ = try decoder.decode(response: .init(), data: data)
            Issue.record("Should have failed")
        } catch let error as StringResponseDecoder.DecodeError {
            print(error)
        }
    }
}
