//
//  Encoding.swift
//  
//
//  Created by rickb on 2/6/21.
//

import Foundation

enum ParameterEncoderError: LocalizedError {
	case cantEncodeData
	case cantEncodeJSON

	var errorDescription: String? {
		switch self {
		case .cantEncodeData:
			return "Can't encode Data"
		case .cantEncodeJSON:
			return "Can't encode JSON"
		}
	}
}

public protocol ParameterEncoder {
	func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest
	func encode(parameters: Data, in request: URLRequest) throws -> URLRequest
}

public extension ParameterEncoder {
	func encode(parameters: Data, in request: URLRequest) throws -> URLRequest {
		throw ParameterEncoderError.cantEncodeData
	}
}

struct OctetStreamParameterEncoder: ParameterEncoder {

	public func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
		throw ParameterEncoderError.cantEncodeJSON
	}

	public func encode(parameters: Data, in request: URLRequest) throws -> URLRequest {
		var modifiedRequest = request
		modifiedRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
		modifiedRequest.httpBody = parameters
		return modifiedRequest
	}
}

public struct URLParameterEncoder: ParameterEncoder {
	let encoder: JSONEncoder

	public init(encoder: JSONEncoder = JSONEncoder()) {
		self.encoder = encoder
	}

	public func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
		var modifiedRequest = request
		modifiedRequest.url = modifiedRequest.url?.addQueryItems(try encoder.encodeToQuery(parameters))
		return modifiedRequest
	}
}

public class FormEncoder: ParameterEncoder {
	let encoder: JSONEncoder

	public init(encoder: JSONEncoder = JSONEncoder()) {
		self.encoder = encoder
	}

	public func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
		var modifiedRequest = request
		modifiedRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		modifiedRequest.httpBody = (try encoder.encodeToQuery(parameters)).map { $0.toString() }.joined(separator: "&").data(using: .utf8)
		return modifiedRequest
	}
}

extension Dictionary where Key == String, Value == Any {

	func getParameters() -> [String: String] {  // not handling arrays, add if needed
		mapValues { "\($0)" }
	}
}

extension JSONEncoder {

	func jsonObject<T: Encodable>(_ value: T) throws -> Any {
		try JSONSerialization.jsonObject(with: try encode(value), options: [])
	}

	func encodeToQuery<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
		let dict = (try jsonObject(value) as? [String: Any])?.getParameters()
		var queryItems = [URLQueryItem]()
		dict?.forEach { key, value in
			queryItems.append(.init(name: key, value: value))
		}
		return queryItems
	}
}

extension URLQueryItem {

	func toString() -> String {
		let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		let value = self.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		return [name, value].compactMap { $0 }.joined(separator: "=")
	}
}

extension URL {

	func addQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
		guard queryItems.isEmpty == false else {
			return self
		}
		var comps = URLComponents(url: self, resolvingAgainstBaseURL: true)
		let items = comps?.queryItems ?? []
		comps?.queryItems = items + queryItems
		return comps?.url
	}
}

extension JSONEncoder {

	public func encode<T: Encodable>(parameters: T, in request: URLRequest) throws -> URLRequest {
		var modifiedRequest = request
		modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		modifiedRequest.httpBody = try encode(parameters)
		return modifiedRequest
	}
}

public extension JSONEncoder {
	var parameterEncoder: ParameterEncoder {
		JSONParameterEncoder(encoder: self)
	}
}

struct JSONParameterEncoder: ParameterEncoder {
	let encoder: JSONEncoder

	func encode<T>(parameters: T, in request: URLRequest) throws -> URLRequest where T : Encodable {
		try encoder.encode(parameters: parameters, in: request)
	}
}

extension URLRequest {

	mutating func encode<T: Encodable>(_ parameters: T, with encoder: ParameterEncoder) throws {
		self = try encoder.encode(parameters: parameters, in: self)
	}

	mutating func encode(_ parameters: Data, with encoder: ParameterEncoder) throws {
		self = try encoder.encode(parameters: parameters, in: self)
	}
}

public protocol ResponseDecoder {
	func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

public extension JSONDecoder {

	var responseDecoder: ResponseDecoder {
		JSONResponseDecoder(decoder: self)
	}
}

struct JSONResponseDecoder: ResponseDecoder {
	let decoder: JSONDecoder

	func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
		try decoder.decode(type, from: data)
	}
}

class StringDecoder: ResponseDecoder {

	enum Error: Swift.Error {
		case stringDecodeError
	}

	func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		if let string = String(data: data, encoding: .utf8) as? T {
			return string
		} else {
			throw Error.stringDecodeError
		}
	}
}

public extension String {

	static let responseDecoder: ResponseDecoder = StringDecoder()
}
