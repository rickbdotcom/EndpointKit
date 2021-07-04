//
//  Session.swift
//
//
//  Created by rickb on 2/2/21.
//

import Combine
import Foundation

extension URLSession {

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response: Decodable {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for:request).validate()
			.tryMap { data, urlResponse in
				try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response: Decodable {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL)
			return dataTaskPublisher(for:request).validate().tryMap { data, urlResponse in
				try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for: request).validate()
			.map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<Void, Error> {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL)
			return dataTaskPublisher(for: request).validate()
			.map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {

	func validate() -> AnyPublisher<Output, Error> {
		tryMap { data, urlResponse in
			try validateHttpResponse(data, urlResponse)
			return (data, urlResponse)
		}.eraseToAnyPublisher()
	}
}
