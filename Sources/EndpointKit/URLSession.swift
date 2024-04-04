//
//  URLSession.swift
//  
//
//  Created by Burgess, Rick on 10/3/23.
//

import Foundation

extension URLSession: URLRequestDataProvider {
    /// URLSession URLRequestDataProvider conformance
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: urlRequest, delegate: nil)
    }
}
