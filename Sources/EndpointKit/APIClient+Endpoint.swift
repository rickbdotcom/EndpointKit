//
//  File.swift
//  
//
//  Created by rickb on 7/2/21.
//

import Foundation

public extension APIClient {

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) async throws -> T.Response {
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
