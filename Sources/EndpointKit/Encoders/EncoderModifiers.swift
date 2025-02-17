//
//  File.swift
//  
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation

extension RequestEncoder {

    /// Modify parameter encoder to merge the headers
    public func merge(
        headers: [String: String],
        uniquingKeysWith combine: @escaping (String, String) -> String = { a, _ in a }
    ) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            let requestHeaders = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = headers.merging(requestHeaders, uniquingKeysWith: combine)
            return request
        }
    }

    /// Modify parameter encoder to remove headers
    public func remove(headers: [String]) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
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
    public func contentType(_ contentType: String) -> any RequestEncoder<Parameters> {
        merge(headers: [ContentType.header: contentType])
    }

    /// Modify the URLRequest cachePolicy
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            request.cachePolicy = policy
            return request
        }
    }

    /// Modify the URLRequest timeout
    public func timeout(_ interval: TimeInterval) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            var request = try await encode(parameters, into: request)
            request.timeoutInterval = interval
            return request
        }
    }
}
