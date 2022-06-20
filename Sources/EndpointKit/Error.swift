//
//  Error.swift
//
//
//  Created by rickb on 2/5/21.
//

import Foundation

extension DecodingError {

	var decodingErrorDescription: String? {
		switch self {
		case let .typeMismatch(_, context):
			return "\(context.debugDescription)\n\(context.codingPath)\n\(context.underlyingError?.localizedDescription ?? "")"
		case let .valueNotFound(_, context):
			return "\(context.debugDescription)\n\(context.codingPath)\n\(context.underlyingError?.localizedDescription ?? "")"
		case let .keyNotFound(_, context):
			return "\(context.debugDescription)\n\(context.codingPath)\n\(context.underlyingError?.localizedDescription ?? "")"
		case let .dataCorrupted(context):
			return "\(context.debugDescription)\n\(context.codingPath)\n\(context.underlyingError?.localizedDescription ?? "")"
		@unknown default:
			return "unknown decoding error"
		}
	}
}

struct ExtendedDecodingError: Error, LocalizedError {

	let decodingError: DecodingError

	var errorDescription: String? {
		decodingError.decodingErrorDescription
	}

	init?(error: Error?) {
		guard let error = error as? DecodingError else { return nil }
		decodingError = error
	}

	init(error: DecodingError) {
		decodingError = error
	}
}

extension Error {

	var extendedError: Error {
		if let error = self as? DecodingError {
			return ExtendedDecodingError(error: error)
		} else {
			return self
		}
	}
}

public struct HTTPError: LocalizedError {
	public let data: Data
	public let response: HTTPURLResponse

	public var errorDescription: String? {
		"HTTP Error: \(response.statusCode)"
	}
}

func validateHttpResponse(_ data: Data, _ response: URLResponse) throws {
	guard let response = response as? HTTPURLResponse else { return }
	let statusCode = response.statusCode
	if statusCode < 200 || statusCode > 399 {
		throw HTTPError(data: data, response: response)
	}
}
