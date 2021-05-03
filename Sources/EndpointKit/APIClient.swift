//
//  APIClient.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Combine
import Foundation

public class APIClient: ObservableObject {
	@Published var session: URLSession

	let baseURL: URL
	let mapApiError: ((HTTPURLResponse, Data) -> Error?)?
	let reauthorize: (() -> AnyPublisher<Void, Error>)?

	public init(baseURL: URL, session: URLSession = URLSession(configuration: .default), mapError: ((HTTPURLResponse, Data) -> Error?)? = nil, reauthorize: (() -> AnyPublisher<Void, Error>)? = nil) {
		self.baseURL = baseURL
		self.session = session
		self.mapApiError = mapError
		self.reauthorize = reauthorize
	}

	public func request<T: APIEndpoint>(_ endpoint: T, retryOnAuthError: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleResponse(mapApiError: mapApiError, retry: retry(retryOnAuthError, self.request(endpoint, retryOnAuthError: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, retryOnAuthError: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleResponse(mapApiError: mapApiError, retry: retry(retryOnAuthError, self.request(endpoint, retryOnAuthError: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, retryOnAuthError: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleResponse(mapApiError: mapApiError, retry: retry(retryOnAuthError, self.request(endpoint, retryOnAuthError: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, retryOnAuthError: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleResponse(mapApiError: mapApiError, retry: retry(retryOnAuthError, self.request(endpoint, retryOnAuthError: false)))
	}
}

extension APIClient {

	func retry<T>(_ retryOnAuthError: Bool, _ request: @autoclosure @escaping () -> AnyPublisher<T, Error>) -> (() -> AnyPublisher<T, Error>)? {
		guard retryOnAuthError, let reauthorize = reauthorize else {
			return nil
		}
		return {
			reauthorize().flatMap {
				request()
			}.eraseToAnyPublisher()
		}
	}
}

extension Publisher {

	func handleResponse(mapApiError: ((HTTPURLResponse, Data) -> Error?)?, retry: (() -> AnyPublisher<Output, Failure>)?) -> AnyPublisher<Output, Failure> where Failure == Error {
		tryCatch { error -> AnyPublisher<Output, Failure> in
			if let retry = retry,
			   (error as? HTTPError)?.response.statusCode == 401 {
				return retry()
			}
			throw error
		}
		.mapError { error in
			if let httpError = error as? HTTPError {
				return mapApiError?(httpError.response, httpError.data) ?? error.extendedError
			} else {
				return error.extendedError
			}
		}
		.printError()
		.eraseToAnyPublisher()
	}

	func printError() -> AnyPublisher<Output, Failure> {
		handleEvents(receiveCompletion: { result in
			if case let .failure(error) = result {
				Swift.print(error.localizedDescription)
			}
		}).eraseToAnyPublisher()
	}
}
