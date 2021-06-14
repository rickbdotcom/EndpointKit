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
			return dataTaskPublisher(for:request).debugPrintRequest(request).validate()
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
			return dataTaskPublisher(for:request).debugPrintRequest(request).validate().tryMap { data, urlResponse in
				try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for: request).debugPrintRequest(request).validate()
			.map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<Void, Error> {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL)
			return dataTaskPublisher(for: request).debugPrintRequest(request).validate()
			.map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Data {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for:request).debugPrintRequest(request).validate()
			.map { data, urlResponse in
				data
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response == Data {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL)
			return dataTaskPublisher(for:request).debugPrintRequest(request).validate().map { data, urlResponse in
				data
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters == Data, T.Response: Decodable {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for:request).debugPrintRequest(request).validate()
			.tryMap { data, urlResponse in
				try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
			}.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters == Data, T.Response == Void {
		do {
			let request = try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
			return dataTaskPublisher(for: request).debugPrintRequest(request).validate()
			.map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}
}

private var printRequests = false

public extension URLSession.DataTaskPublisher {

	static func setDebugPrintRequest(_ enable: Bool) {
		printRequests = enable
	}
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {

	func validate() -> AnyPublisher<Output, Error> {
		tryMap { data, urlResponse in
			if let response = urlResponse as? HTTPURLResponse {
				let statusCode = response.statusCode
				if statusCode < 200 || statusCode > 399 {
					throw HTTPError(data: data, response: response)
				}
			}
			return (data, urlResponse)
		}.eraseToAnyPublisher()
	}

	func debugPrintRequest(_ request: URLRequest) -> AnyPublisher<Output, Failure> {
		handleEvents(
			receiveSubscription: { _ in
				if printRequests {
					Swift.print(request.curl)
				}
			},
			receiveOutput: { data, urlResponse in
				if printRequests {
					Swift.print(urlResponse.debugDescription)
					if let json = try? JSONSerialization.jsonObject(with: data, options: []),
					   let stringData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
					   let string = String(data: stringData, encoding: .utf8) {
						Swift.print(string)
					} else if let string = String(data: data, encoding: .utf8) {
						Swift.print(string)
					}
				}
			}
		).eraseToAnyPublisher()
	}
}

struct HTTPError: LocalizedError {
	let data: Data
	let response: HTTPURLResponse

	var errorDescription: String? {
		"HTTP Error: \(response.statusCode)"
	}
}
