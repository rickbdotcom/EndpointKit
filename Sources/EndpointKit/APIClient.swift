//
//  APIClient.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Foundation

public class APIClient: ObservableObject, APIClientProtocol {
	@Published public var session: URLSession

	public typealias MapAPIError = (HTTPURLResponse, Data) -> Error?
	public typealias Recover = ((APIClient, Error) async throws -> Void)

	public let baseURL: URL
	public let mapApiError: MapAPIError?
	public let recover: Recover?

	public init(baseURL: URL, session: URLSession = URLSession(configuration: .default), mapApiError: MapAPIError? = nil, recover: Recover? = nil) {
		self.baseURL = baseURL
		self.session = session
		self.mapApiError = mapApiError
		self.recover = recover
	}
}

public extension APIClient {

	func request<T: APIEndpoint>(_ endpoint: T) async throws -> T.Response {
		try await request(endpoint, attemptRecovery: true)
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool) async throws -> T.Response {
		do {
			return try await session.request(endpoint, baseURL: baseURL)
		} catch {
			do {
				return try await retry(error, attemptRecovery, try await self.request(endpoint, attemptRecovery: false))
			} catch {
				if let httpError = error as? HTTPError {
					throw mapApiError?(httpError.response, httpError.data) ?? error.extendedError
				} else {
					throw error.extendedError
				}
			}
		}
	}
}

extension APIClient {

	func retry<T>(_ error: Error, _ attemptRecovery: Bool, _ request: @autoclosure @escaping () async throws -> T) async throws -> T {
		guard attemptRecovery, let recover = self.recover else {
			throw error
		}
		try await recover(self, error)
		return try await request()
	}
}
