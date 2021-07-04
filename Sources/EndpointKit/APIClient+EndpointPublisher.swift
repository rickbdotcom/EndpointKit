//
//  APIClient.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Combine
import Foundation

public extension APIClient {
	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}
}

extension APIClient {

	func retry<T>(_ attemptRecovery: Bool, _ request: @autoclosure @escaping () -> AnyPublisher<T, Error>) -> ((Error) -> AnyPublisher<T, Error>) {
		return { error in
			guard attemptRecovery, let recover = self.recover else {
				return Fail(error: error).eraseToAnyPublisher()
			}
			return recover.recoverPublisher(self, error).flatMap {
				request()
			}.eraseToAnyPublisher()
		}
	}
}

extension Publisher {

	func handleApiResponse(mapApiError: ((HTTPURLResponse, Data) -> Error?)?, retry: @escaping ((Error) -> AnyPublisher<Output, Failure>)) -> AnyPublisher<Output, Failure> where Failure == Error {
		tryCatch { error in
			retry(error)
		}
		.mapError { error in
			if let httpError = error as? HTTPError {
				return mapApiError?(httpError.response, httpError.data) ?? error.extendedError
			} else {
				return error.extendedError
			}
		}
		.eraseToAnyPublisher()
	}
}
