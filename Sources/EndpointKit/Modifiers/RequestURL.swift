//
//  File.swift
//  EndpointKit
//
//  Created by rickb on 5/15/25.
//

import Foundation

extension AnyEndpointModifier {

    public static func map(url: @Sendable @escaping (URL) -> URL) -> Self {
        RequestModifier {
            $0.map(url: url)
        }.any()
    }

    public static func map(urlComponents: @Sendable @escaping (URLComponents) -> URLComponents) -> Self {
        RequestModifier {
            $0.map(urlComponents: urlComponents)
        }.any()
    }

    public static func mapURLComponents(host: String? = nil, path: String? = nil) -> Self {
        map {
            var comp = $0
            if let host {
                comp.host = host
            }
            if let path {
                comp.path = path
            }
            return comp
        }
    }
}

extension RequestEncoder {

    public func map(url: @Sendable @escaping (URL) -> URL) -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, inRequest in
            var request = inRequest
            if let requestURL = request.url {
                request.url = url(requestURL)
            }
            return try await encode(parameters, into: request)
        }
    }

    public func map(urlComponents: @Sendable @escaping (URLComponents) -> URLComponents) -> any RequestEncoder<Parameters> {
        map { url in
            if var comp = URLComponents(url: url, resolvingAgainstBaseURL: true)  {
                comp = urlComponents(comp)
                if let newURL = comp.url {
                    return newURL
                }
            }
            return url
        }
    }
}
