//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 4/17/25.
//

import Foundation

extension AnyEndpointModifier {

    public static func cURL() -> Self {
        RequestModifier { $0.cURL() }.any()
    }
}

extension RequestEncoder {

    public func cURL() -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            let request = try await encode(parameters, into: request)
            print(request.cURL())
            return request
        }
    }

}
extension URLRequest {

    public func cURL() -> String {
        let cURL = "curl -f"
        let method = "-X \(self.httpMethod ?? "GET")"
        let url = url.flatMap { "--url '\($0.absoluteString)'" }

        let header = self.allHTTPHeaderFields?
            .map { "-H '\($0): \($1)'" }
            .joined(separator: " ")

        let data: String?
        if let httpBody, !httpBody.isEmpty {
            if let bodyString = String(data: httpBody, encoding: .utf8) { // json and plain text
                let escaped = bodyString
                    .replacingOccurrences(of: "'", with: "'\\''")
                data = "--data '\(escaped)'"
            } else { // Binary data
                let hexString = httpBody
                    .map { String(format: "%02X", $0) }
                    .joined()
                data = #"--data "$(echo '\#(hexString)' | xxd -p -r)""#
            }
        } else {
            data = nil
        }

        return [cURL, method, url, header, data]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
