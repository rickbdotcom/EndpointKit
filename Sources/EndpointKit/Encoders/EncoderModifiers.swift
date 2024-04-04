//
//  File.swift
//  
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

extension ParameterEncoder {

    /// Modify parameter encoder to merge the headers
    public func merge(
        headers: [String: String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { a, _ in a }
    ) -> any ParameterEncoder<Parameters> {
        AnyParameterEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            let requestHeaders = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = headers.merging(requestHeaders, uniquingKeysWith: combine)
            return request
        }
    }

    /// Modify parameter encoder to remove headers
    public func remove(headers: [String]) -> any ParameterEncoder<Parameters> {
        AnyParameterEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            if let requestHeaders = request.allHTTPHeaderFields {
                request.allHTTPHeaderFields = requestHeaders.filter { key, _ in
                    headers.contains(key) == false
                }
            }
            return request
        }
    }

    /// Modify parameter encoder to set content type
    public func contentType(_ contentType: String) -> any ParameterEncoder<Parameters> {
        merge(headers: [ContentType.header: contentType])
    }
}
