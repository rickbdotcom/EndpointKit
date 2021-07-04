//
//  File.swift
//  
//
//  Created by rickb on 7/3/21.
//
#if swift(>=5.5)

import Foundation
import CoreData

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension URLSession {

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response where T.Parameters: Encodable, T.Response: Decodable {
		let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
		let (data, response) = try await data(for: request)
		try validateHttpResponse(data, response)
		return try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response where T.Parameters == Void, T.Response: Decodable {
		let request = try endpoint.endpoint.request(baseURL: baseURL)
		let (data, response) = try await data(for: request)
		try validateHttpResponse(data, response)
		return try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response where T.Parameters: Encodable, T.Response == Void {
		let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
		let (data, response) = try await data(for: request)
		try validateHttpResponse(data, response)
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response where T.Parameters == Void, T.Response == Void {
		let request = try endpoint.endpoint.request(baseURL: baseURL)
		let (data, response) = try await data(for: request)
		try validateHttpResponse(data, response)
	}
}

#endif
