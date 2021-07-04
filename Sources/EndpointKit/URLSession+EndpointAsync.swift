//
//  File.swift
//  
//
//  Created by rickb on 7/3/21.
//
#if swift(>=5.5)

import Foundation
import CoreData

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension URLSession {

	func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) async throws -> T.Response {
		let request = try endpoint.request(baseURL: baseURL)
		let (data, response) = try await data(for: request)
		try validateHttpResponse(data, response)
		return try endpoint.decode(from: data)
	}
}
#endif
