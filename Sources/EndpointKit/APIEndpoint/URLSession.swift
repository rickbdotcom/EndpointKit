//
//  File.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

extension URLSession: URLRequestDataProvider {
    /// URLSession URLRequestDataProvider conformance
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        guard #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) else {
            return try await withCheckedThrowingContinuation { continuation in
                dataTask(with: urlRequest) { data, response, error in
                    if let data, let response {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: error ?? CancellationError())
                    }
                }
            }
        }
        return try await data(for: urlRequest, delegate: nil)
    }
}
