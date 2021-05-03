//
//  Endpoint.swift
//
//
//  Created by rickb on 1/30/21.
//

import Foundation

public protocol APIEndpoint {
	associatedtype Parameters = Void
	associatedtype Response = Void

	var parameters: Parameters { get }
	var endpoint: Endpoint { get }
}

extension APIEndpoint where Parameters == Void {
  var parameters: () { () }
}

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
	case head = "HEAD"

	var defaultEncoding: ParameterEncoder {
		switch self {
		case .get:
			return URLParameterEncoder()
		default:
			return JSONEncoder().parameterEncoder
		}
	}
}

public struct Endpoint: ExpressibleByStringLiteral {
	public let path: String
	public let method: HTTPMethod
	public let headers: [String: String]?
	public let encoder: ParameterEncoder
	public let decoder: ResponseDecoder

	public init(_ path: String, _ method: HTTPMethod, encoder: ParameterEncoder? = nil, decoder: ResponseDecoder = JSONDecoder().responseDecoder, headers: [String: String]? = nil) {
		self.path = path
		self.method = method
		self.headers = headers
		self.encoder = encoder ?? method.defaultEncoding
		self.decoder = decoder
	}

	public init(stringLiteral: StringLiteralType) {
		let comps = stringLiteral.components(separatedBy: " ")
		guard comps.count == 2,
			  let method = HTTPMethod(rawValue: comps[0]) else {
			preconditionFailure("Invalid Endpoint string: \(stringLiteral)")
		}

		self.path = comps[1]
		self.method = method
		self.headers = nil
		self.encoder = method.defaultEncoding
		self.decoder = JSONDecoder().responseDecoder
	}
}

public extension Endpoint {

	func request<T: Encodable>(baseURL: URL, parameters: T) throws -> URLRequest {
		var request = try self.request(baseURL: baseURL)
		try request.encode(parameters, with: encoder)
		return request
	}

	func request(baseURL: URL) throws -> URLRequest {
		let url = baseURL.appendingPathComponent(path)
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		headers?.forEach { key, value in
			request.setValue(value, forHTTPHeaderField: key)
		}
		return request
	}
}
