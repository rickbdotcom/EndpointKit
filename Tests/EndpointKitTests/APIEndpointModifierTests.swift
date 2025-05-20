//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import Testing
@testable import EndpointKit

struct ResponseValidation {
    @Test(arguments: [true, false])
    func validateDecodableError(requireHttpError: Bool) async throws {
        struct CustomError: Error, Decodable {
            let errorCode: Int
        }
        var dataProvider = TestDataProvider(body: #"{"errorCode": 1}"#, statusCode: requireHttpError ? 400 : 200)
        let endpoint = TestEmptyEndpoint().modify(.validate(error: CustomError.self, requireHttpError: requireHttpError))
        do {
            try await dataProvider.request(endpoint: endpoint)
            Issue.record("Should have failed")
        } catch let error as CustomError {
            #expect(error.errorCode == 1)
        }

        dataProvider.body = Data()
        dataProvider.statusCode = 200
        try await dataProvider.request(endpoint: endpoint)
    }

    @Test(arguments: [true, false])
    func validateError(requiresHttpError: Bool) async throws {
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

        var dataProvider = TestDataProvider(body: "1", statusCode: requiresHttpError ? 400 : 200)
        let endpoint = TestEmptyEndpoint().modify(.validate(
            error: CustomStringError.self,
            decoder: CustomStringError.Decoder(),
            requireHttpError: requiresHttpError
        ))
        do {
            try await dataProvider.request(endpoint: endpoint)
            Issue.record("Should have failed")
        } catch let error as CustomStringError {
            #expect(error.errorCode == 1)
        }

        dataProvider.body = Data()
        dataProvider.statusCode = 200
        try await dataProvider.request(endpoint: endpoint)
    }

    @Test func validateHTTP() async throws {

    }

/*    @Test func errorValidator() async throws {

        let errorDataProvider = TestDataProvider(body: #"{"errorCode": 1}"#, statusCode: 400)

        do {
            _ = try await errorDataProvider.request(baseURL: API.baseURL, endpoint: endpoint)
            Issue.record("Should have failed")
        } catch let error as API.CustomError {
            #expect(error.errorCode == 1)
        }


        /*        try await customError(API.Track(parameters: .init(
         action: "login"
         )), body: #"{"errorCode": 1}"#)

         let loginWithCustomError = API.Login(parameters: .init(username: "rickb", password: "password"))
         .modify(.validate(error: API.CustomError.self))
         try await customError(loginWithCustomError, body: #"{"errorCode": 1}"#)

         let loginWithCustomStringError = API.Login(parameters: .init(username: "rickb", password: "password"))
         .modify(.validate(error: API.CustomStringError.self, decoder: API.CustomStringErrorDecoder()))
         try await customError(loginWithCustomStringError, body: "1")*/
    }*/
}
/*
    func customError<T: Endpoint>(_ endpoint: T, body: String) async throws {
        let errorDataProvider = TestDataProvider(body: body, statusCode: 400)

        do {
            _ = try await errorDataProvider.request(baseURL: API.baseURL, endpoint: endpoint)
            Issue.record("Should have failed")
        } catch let error as API.CustomError {
            #expect(error.errorCode == 1)
        } catch let error as API.CustomStringError {
            #expect(error.errorCode == 1)
        }
    }
/*
    @Test func modifyErrorValidator() async throws {
        let track = API.Track(parameters: .init(
            action: "login"
        )).modify {
            $0.validate(error: StringError.self, decoder: StringErrorDecoder())
        }

        let stringErrorDataProvider = TestDataProvider(body: "An error", statusCode: 400)
        do {
            try await stringErrorDataProvider.request(baseURL: API.baseURL, endpoint: track)
            Issue.record("Should have failed")
        } catch let error as StringError {
            #expect(error.localizedDescription == "An error")
        }

        let dataProvider = TestDataProvider(body: "")
        try await dataProvider.request(baseURL: API.baseURL, endpoint: track)
    }*/

    @Test func heeaders() async throws {
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

        var urlRequest = URLRequest(url: URL("https://www.google.com")!)
        urlRequest.merge(headers: ["pageName": "home"])
// fixem rickb
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
            Issue.record("Should have failed")
        } catch let error as API.CustomError {
            #expect(error.errorCode == 1)
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
        #expect(result == "123")
    }
}
*/
