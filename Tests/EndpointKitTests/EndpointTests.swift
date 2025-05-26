//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//
import Testing
import Foundation
@testable import EndpointKit

struct RouteTests {
    @Test(arguments: [
        (GET("get"), HTTPMethod.get),
        (POST("post"), HTTPMethod.post),
        (PUT("put"), HTTPMethod.put),
        (DELETE("delete"), HTTPMethod.delete),
        (HEAD("head"), HTTPMethod.head),
    ]) func check(test: (Route, HTTPMethod)) {
        #expect(test.0.method == test.1)
        #expect(test.0.path == test.0.method.rawValue.lowercased())
    }
}

struct HTTPMethodTests {

    @Test(arguments: [
        (HTTPMethod.get, "GET"),
        (HTTPMethod.post, "POST"),
        (HTTPMethod.put, "PUT"),
        (HTTPMethod.delete, "DELETE"),
        (HTTPMethod.head, "HEAD")
    ]) func check(test: (HTTPMethod, String)) {
        #expect(test.0.rawValue == test.1)
    }
}

struct HTTPErrorTests {

    @Test(arguments: [
        (100, true),
        (200, false),
        (300, false),
        (400, true),
        (500, true)
    ]) func statusCode(test: (Int, Bool)) {
        #expect(HTTPError.isError(test.0) == test.1)
    }

    @Test func check() throws {
        let response = try #require(HTTPURLResponse(
            url: .test,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        ))
        let data = Data("hello".utf8)

        do {
            try HTTPError.throwIfError(response: response, data: data)
            Issue.record("Should have failed")
        } catch let error as HTTPError {
            #expect(error.response == response)
            #expect(error.data == data)
            #expect(error.statusCode == 400)
            #expect(error.errorDescription == "HTTP Error: 400")
            #expect(error.responseString == "hello")
        }
    }
}
