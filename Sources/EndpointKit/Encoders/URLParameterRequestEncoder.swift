//
//  URLRequestEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

public enum URLParameterArrayEncoding: Sendable {
    case noBrackets
    case brackets
    case commaSeparated
}

/// Encodes parameters into URL query, i.e. ?item=1&next=2
public struct URLParameterRequestEncoder<T: Encodable>: RequestEncoder {
    public typealias Parameters = T

    let encoder: JSONEncoder
    let arrayEncoding: URLParameterArrayEncoding

    public init(
        encoder: JSONEncoder = JSONEncoder(),
        arrayEncoding: URLParameterArrayEncoding = .noBrackets
    ) {
        self.encoder = encoder
        self.arrayEncoding = arrayEncoding
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.url = try modifiedRequest.url?.addQueryItems(
            encoder.encodeToQuery(parameters, arrayEncoding: arrayEncoding)
        )
        return modifiedRequest
    }
}

private extension URL {

    func addQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let items = components?.queryItems ?? []
        components?.queryItems = items + queryItems
        return components?.url
    }
}

extension JSONEncoder {

    func jsonObject<T: Encodable>(_ value: T) throws -> Any {
        try JSONSerialization.jsonObject(with: try encode(value), options: [])
    }

    func encodeToQuery<T: Encodable>(
        _ value: T,
        arrayEncoding: URLParameterArrayEncoding
    ) throws -> [URLQueryItem] {
        let keyValues = (try jsonObject(value) as? [String: Any])?.parameters(arrayEncoding)
        var queryItems = [URLQueryItem]()
        keyValues?.sorted {
            $0.0 < $1.0
        }.forEach {
            queryItems.append(.init(name: $0, value: $1))
        }
        return queryItems
    }
}

extension Dictionary where Key == String, Value == Any {

    func parameters(_ arrayEncoding: URLParameterArrayEncoding) -> [(String, String)] {
        flatMap { key, value in
            if let array = value as? [Any] {
                switch arrayEncoding {
                case .noBrackets:
                    array.map {
                        (key, "\($0)")
                    }
                case .brackets:
                    array.map {
                        ("\(key)[]", "\($0)")
                    }
                case .commaSeparated:
                    [(key, array.map { "\($0)" }.joined(separator: ","))]
                }
            } else {
                [(key, "\(value)")]
            }
        }
    }
}
