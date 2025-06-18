//
//  FormParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// Encode parameters into HTTP body using form encoding (x-www-form-urlencoded)
public struct FormParameterEncoder<T: Encodable>: RequestEncoder {
    public typealias Parameters = T

    let encoder: JSONEncoder
    let arrayEncoding: URLParameterArrayEncoding

    public init(
        encoder: JSONEncoder = JSONEncoder(),
        arrayEncoding: URLParameterArrayEncoding = .duplicateKeys
    ) {
        self.encoder = encoder
        self.arrayEncoding = arrayEncoding
    }

    /// Encode implementation
    public func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(ContentType.formEncoded, forHTTPHeaderField: ContentType.header)
        modifiedRequest.httpBody = (
            try encoder.encodeToQuery(parameters, arrayEncoding: arrayEncoding)
        ).map {
            $0.toString
        }
        .joined(separator: "&")
        .data(using: .utf8)
        
        return modifiedRequest
    }
}

private extension URLQueryItem {

    /// Convert the url query item into a string
    var toString: String {
        let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let value = self.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return [name, value].compactMap { $0 }.joined(separator: "=")
    }
}
