//
//  File.swift
//  
//
//  Created by rickb on 7/2/21.
//

import Foundation

public class MockAPIClient: APIClientProtocol {

	var endpointHandlers = [UUID: Any]()

	public init() {

	}
}

public extension MockAPIClient {

	@discardableResult
	func registerMockEndpoint<T: APIEndpoint>(_ handler: @escaping (T) throws -> T.Response?) -> Any {
		let token = UUID()
		endpointHandlers[token] = handler
		return token
	}

	@discardableResult
	func registerMockEndpoint<T: APIEndpoint & Equatable>(withFilePath path: String, endpoint: T) -> Any {
		registerMockEndpoint { (match: T) in
			guard match == endpoint else {
				return nil
			}
			return try endpoint.decode(withFilePath: path)
		}
	}

	func removeMockEndpoint(_ token: Any) {
		if let token = token as? UUID {
			endpointHandlers[token] = nil
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T) async throws -> T.Response {
		for handler in endpointHandlers.values {
			if let handler = handler as? ((T) throws -> T.Response?),
			   let response = try handler(endpoint) {
				return response
			}
		}
		throw MockError.noHandlerFound(endpoint.endpoint.path)
	}

	enum MockError: LocalizedError {
		case noHandlerFound(String)
		case fileNotFound(String)

		public var errorDescription: String? {
			switch self {
			case let .noHandlerFound(string):
				return "No mock endpoint handler found for \(string)"
			case let .fileNotFound(string):
				return "Mock file not found \(string)"
			}
		}
	}
}

public extension APIEndpoint {

	func decode(withFilePath path: String) throws -> Response {
		guard FileManager.default.fileExists(atPath: path) else {
			throw MockAPIClient.MockError.fileNotFound(path)
		}
		let url = URL(fileURLWithPath: path)
		let data = try Data(contentsOf: url)
		return try decode(from: data)
	}
}
