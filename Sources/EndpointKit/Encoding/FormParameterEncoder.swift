//
//  FormParameterEncoder.swift
//  EndpointKit
//
//  Created by Richard Burgess on 6/13/2023
//  
//

import Foundation

/// Encode parameters into HTTP body using form encoding (x-www-form-urlencoded)
public struct FormParameterEncoder: ParameterEncoder {
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

private extension URLQueryItem {

    func toString() -> String {
        let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let value = self.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return [name, value].compactMap { $0 }.joined(separator: "=")
    }
}
