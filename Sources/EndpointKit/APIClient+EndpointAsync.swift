//
//  File.swift
//  
//
//  Created by rickb on 7/2/21.
//
#if swift(>=5.5)

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public extension APIClient {

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) async throws -> T.Response where T.Parameters: Encodable, T.Response: Decodable {
		do {
			return try await session.request(endpoint, baseURL: baseURL)
		} catch {
			return try await retry(error, attemptRecovery, try await self.request(endpoint, attemptRecovery: false))
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) async throws -> T.Response where T.Parameters == Void, T.Response: Decodable {
		do {
			return try await session.request(endpoint, baseURL: baseURL)
		} catch {
			return try await retry(error, attemptRecovery, try await self.request(endpoint, attemptRecovery: false))
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) async throws -> T.Response where T.Parameters: Encodable, T.Response == Void {
		do {
			return try await session.request(endpoint, baseURL: baseURL)
		} catch {
			return try await retry(error, attemptRecovery, try await self.request(endpoint, attemptRecovery: false))
		}
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) async throws -> T.Response where T.Parameters == Void, T.Response == Void {
		do {
			return try await session.request(endpoint, baseURL: baseURL)
		} catch {
			return try await retry(error, attemptRecovery, try await self.request(endpoint, attemptRecovery: false))
		}
	}
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension APIClient {

	func retry<T>(_ error: Error, _ attemptRecovery: Bool, _ request: @autoclosure @escaping () async throws -> T) async throws -> T {
		guard attemptRecovery, let recover = self.recover else {
			throw error
		}
		try await recover.recoverAsync(self, error)
		return try await request()
	}
}
#endif
