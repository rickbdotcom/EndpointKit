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

	func request(baseURL: URL) throws -> URLRequest
	func decode(from: Data) throws -> Response
}

public extension APIEndpoint where Parameters == Void {
  var parameters: () { () }
}

public extension APIEndpoint where Parameters == Void {

	func request(baseURL: URL) throws -> URLRequest {
		try endpoint.request(baseURL: baseURL)
	}
}

public extension APIEndpoint where Parameters: Encodable {

	func request(baseURL: URL) throws -> URLRequest {
		var request = try endpoint.request(baseURL: baseURL)
		try request.encode(parameters, with: endpoint.encoder)
		return request
	}
}

public extension APIEndpoint where Parameters == Data {

	func request(baseURL: URL) throws -> URLRequest {
		var request = try endpoint.request(baseURL: baseURL)
		do {
			try request.encode(parameters, with: endpoint.encoder)
		} catch {
			try request.encode(parameters, with: DataParameterEncoder())
		}
		return request
	}
}

public extension APIEndpoint where Parameters == [String: Any] {

	func request(baseURL: URL) throws -> URLRequest {
		var request = try endpoint.request(baseURL: baseURL)
		do {
			try request.encode(parameters, with: endpoint.encoder)
		} catch {
			try request.encode(parameters, with: DictionaryParameterEncoder())
		}
		return request
	}
}

public extension APIEndpoint where Response == Void {

	func decode(from: Data) throws -> Response {
		()
	}
}

public extension APIEndpoint where Response: Decodable {

	func decode(from data: Data) throws -> Response {
		try endpoint.decoder.decode(Response.self, from: data)
	}
}

public extension APIEndpoint where Response == Data {

	func decode(from data: Data) throws -> Response {
		do {
			return try endpoint.decoder.decode(from: data)
		} catch {
			return try DataResponseDecoder().decode(from: data)
		}
	}
}

public extension APIEndpoint where Response == [String: Any] {

	func decode(from data: Data) throws -> Response {
		do {
			return try endpoint.decoder.decode(from: data)
		} catch {
			return try DictionaryResponseDecoder().decode(from: data)
		}
	}
}

public enum HTTPMethod: String, Equatable {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
	case head = "HEAD"

	var defaultEncoding: ParameterEncoder {
		switch self {
		case .get:
			return URLParameterEncoder(encoder: defaultEncoder)
		default:
			return defaultEncoder.parameterEncoder
		}
	}
}

public struct Endpoint: Equatable, ExpressibleByStringLiteral {
	public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
		lhs.path == rhs.path &&
		lhs.method == rhs.method &&
		lhs.headers == rhs.headers
// TODO
//		lhs.encoder == rhs.encoder &&
//		lhs.decoder == rhs.decoder
	}

	public let path: String
	public let method: HTTPMethod
	public let headers: [String: String]?
	public let encoder: ParameterEncoder
	public let decoder: ResponseDecoder

	public init(_ path: String, _ method: HTTPMethod, encoder: ParameterEncoder? = nil, decoder: ResponseDecoder = defaultDecoder.responseDecoder, headers: [String: String]? = nil) {
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
		self.decoder = defaultDecoder.responseDecoder
	}
}

public extension Endpoint {

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

extension JSONDecoder.DateDecodingStrategy {
	static let customISO8601 = custom {
		let container = try $0.singleValueContainer()
		let string = try container.decode(String.self)
		if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ?? Formatter.iso8601.date(from: string) {
			return date
		}
		throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
	}
}

extension JSONEncoder.DateEncodingStrategy {
	static let customISO8601 = custom {
		var container = $1.singleValueContainer()
		try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
	}
}

extension Formatter {
	static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()
	static let iso8601: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()
}

public let defaultEncoder: JSONEncoder = {
	let encoder = JSONEncoder()
	encoder.dateEncodingStrategy = .customISO8601
	return encoder
}()

public let defaultDecoder: JSONDecoder = {
	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .customISO8601
	return decoder
}()
