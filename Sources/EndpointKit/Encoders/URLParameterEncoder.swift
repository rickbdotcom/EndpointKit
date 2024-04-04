//
//  URLParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Encodes parameters into URL query, i.e. ?item=1&next=2
/// - Warning: Doesn't support arrays as there is no standard way to encode them. TODO: US1893651
/// https://medium.com/raml-api/objects-in-query-params-173d2712ce5b
public struct URLParameterEncoder<T: Encodable>: ParameterEncoder {
    public typealias Parameters = T

    let encoder: JSONEncoder

    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.url = try modifiedRequest.url?.addQueryItems(encoder.encodeToQuery(parameters))
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

    func encodeToQuery<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let dictionary = (try jsonObject(value) as? [String: Any])?.parameters
        var queryItems = [URLQueryItem]()
        dictionary?.sorted {
            $0.key < $1.key
        }.forEach { key, value in
            queryItems.append(.init(name: key, value: value))
        }
        return queryItems
    }
}

extension Dictionary where Key == String, Value == Any {

    var parameters: [String: String] {  // not handling arrays, add if needed. US1893651
        mapValues { "\($0)" }
    }
}
