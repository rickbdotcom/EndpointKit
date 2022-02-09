//
//  File.swift
//  
//
//  Created by rickb on 7/3/21.
//

import Foundation

extension URLSession {

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response {
		let request = try endpoint.request(baseURL: baseURL)
		let (data, response) = try await dataAsync(for: request)
		try validateHttpResponse(data, response)
		return try endpoint.decode(from: data)
	}

	func dataAsync(for request: URLRequest) async throws -> (Data, URLResponse) {
		if #available(iOS 15.0, *) {
			return try await data(for: request)
		} else {
			return try await withCheckedThrowingContinuation { continuation in
				dataTask(with: request) { data, response, error in
					if let data = data, let response = response {
						continuation.resume(returning: (data, response))
					} else if let error = error {
						continuation.resume(throwing: error)
					} else {
						assertionFailure("parameter error")
					}
				}
			}
		}
	}
}
