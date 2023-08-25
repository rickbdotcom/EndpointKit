//
//  URLParameterEncoder.swift
//  AmericanCoreNetworking
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Encodes parameters into URL query, i.e. ?item=1&next=2
/// Doesn't currently handling array encoding, i.e. ?item[0]=first&item[1]=second
public struct URLParameterEncoder<T: Encodable>: ParameterEncoder {
    public typealias Parameters = T
    
    let encoder: JSONEncoder

    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.url = try modifiedRequest.url?.addQueryItems(encoder.encodeToQuery(parameters))
        return modifiedRequest
    }
}

private extension URL {

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

    func jsonObject<T: Encodable>(_ value: T) throws -> Any {
        try JSONSerialization.jsonObject(with: try encode(value), options: [])
    }

    func encodeToQuery<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let dict = (try jsonObject(value) as? [String: Any])?.getParameters()
        var queryItems = [URLQueryItem]()
        dict?.sorted {
            $0.key < $1.key
        }.forEach { key, value in
            queryItems.append(.init(name: key, value: value))
        }
        return queryItems
    }
}

extension Dictionary where Key == String, Value == Any {

    func getParameters() -> [String: String] {  // not handling arrays, add if needed
        mapValues { "\($0)" }
    }
}
