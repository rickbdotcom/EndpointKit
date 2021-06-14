//
//  APIClient.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Combine
import Foundation

public class APIClient: ObservableObject {
	@Published public var session: URLSession

	public typealias MapAPIError = ((HTTPURLResponse, Data) -> Error?)
	public typealias Recover = ((APIClient, Error) -> AnyPublisher<Void, Error>?)

	let baseURL: URL
	let mapApiError: MapAPIError?
	let recover: Recover?

	public static var printApiErrors: Bool = false

	public init(baseURL: URL, session: URLSession = URLSession(configuration: .default), mapApiError: MapAPIError? = nil, recover: Recover? = nil) {
		self.baseURL = baseURL
		self.session = session
		self.mapApiError = mapApiError
		self.recover = recover
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Data {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response == Data {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Data, T.Response: Decodable {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}

	public func request<T: APIEndpoint>(_ endpoint: T, attemptRecovery: Bool = true) -> AnyPublisher<T.Response, Error> where T.Parameters == Data, T.Response == Void {
		session.request(endpoint, baseURL: baseURL)
			.handleApiResponse(mapApiError: mapApiError, retry: retry(attemptRecovery, self.request(endpoint, attemptRecovery: false)))
	}
}

public extension APIClient {

	func retry<T>(_ attemptRecovery: Bool, _ request: @autoclosure @escaping () -> AnyPublisher<T, Error>) -> ((Error) -> AnyPublisher<T, Error>?)? {
		guard attemptRecovery, let recover = recover else {
			return nil
		}
		return { error in
			if let recover = recover(self, error) {
				return recover.flatMap {
					request()
				}.eraseToAnyPublisher()
			} else {
				return nil
			}
		}
	}

	static func retryUnauthorized(_ reauthorize: @escaping (APIClient) -> AnyPublisher<Void, Error>?) -> Recover? {
		{ client, error in
			if (error as? HTTPError)?.response.statusCode == 401 {
				return reauthorize(client)
			} else {
				return nil
			}
		}
	}
}

public extension Publisher {

	func handleApiResponse(mapApiError: ((HTTPURLResponse, Data) -> Error?)?, retry: ((Error) -> AnyPublisher<Output, Failure>?)?) -> AnyPublisher<Output, Failure> where Failure == Error {
		tryCatch { error -> AnyPublisher<Output, Failure> in
			if let retry = retry?(error) {
				return retry
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
		.printApiError()
		.eraseToAnyPublisher()
	}

	func printApiError() -> AnyPublisher<Output, Failure> {
		handleEvents(receiveCompletion: { result in
			if APIClient.printApiErrors, case let .failure(error) = result {
				Swift.print(error.localizedDescription)
			}
		}).eraseToAnyPublisher()
	}
}
