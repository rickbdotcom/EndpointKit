//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick on 4/17/25.
//

import Foundation

extension AnyEndpointModifier {

    public static func curl() -> Self {
        RequestModifier {
            $0.curl()
        }.any()
    }
}

extension RequestEncoder {

    public func curl() -> any RequestEncoder<Parameters> {
        AnyRequestEncoder { parameters, request in
            let request = try await encode(parameters, into: request)
            print(request.curl())
            return request
        }
    }
}

extension URLRequest {

    public init?(curl: String) {
        var method = "GET"
        var headers: [String: String] = [:]
        var body: Data?
        var url: URL?

        let tokens = curl.tokenizeForCurl()

        var i = 0
        while i < tokens.count {
            let token = tokens[i]
            switch token {
            case "curl":
                break
            case "-X":
                i += 1
                if i < tokens.count { method = tokens[i] }
            case "-H":
                i += 1
                if i < tokens.count {
                    let header = tokens[i]
                    let parts = header.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        headers[parts[0]] = parts[1]
                    }
                }
            case "--data", "--data-raw":
                i += 1
                if i < tokens.count {
                    body = tokens[i].data(using: .utf8)
                }
/*            case "--data-binary": // assume shell hex escaping
                i += 1
                if i < tokens.count {
                    let binaryString = tokens[i]
                    guard binaryString(0..<1)
                }*/
            default:
                if token.starts(with: "http://") || token.starts(with: "https://") {
                    url = URL(string: token)
                }
            }
            i += 1
        }

        guard let finalURL = url else {
            return nil
        }

        self.init(url: finalURL)
        self.httpMethod = method
        self.allHTTPHeaderFields = headers
        self.httpBody = body
    }

    public func curl() -> String {
        let cURL = "curl -f"
        let method = "-X \(self.httpMethod ?? "")"
        let url = url.flatMap { "--url '\($0.absoluteString)'" }

        let header = self.allHTTPHeaderFields?
            .map { "-H '\($0): \($1)'" }
            .joined(separator: " ")

        var data: String?
        if let httpBody, httpBody.isEmpty == false {
            if let bodyString = String(data: httpBody, encoding: .utf8) { // json and plain text
                let escaped = bodyString
                    .replacingOccurrences(of: "'", with: "'\\''")
                data = "--data '\(escaped)'"
            } else { // Binary data
                let hexString = httpBody
                    .map { String(format: "\\x%02X", $0) }
                    .joined()
                data = "--data-binary $'\(hexString)'"
            }
        }

        return [cURL, method, url, header, data]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

private extension String {

    func tokenizeForCurl() -> [String] {
        var tokens: [String] = []
        var current = ""
        var inSingleQuote = false
        var inDoubleQuote = false

        var iterator = makeIterator()
        while let char = iterator.next() {
            switch char {
            case "'":
                if !inDoubleQuote {
                    inSingleQuote.toggle()
                    if !inSingleQuote {
                        tokens.append(current)
                        current = ""
                    }
                } else {
                    current.append(char)
                }
            case "\"":
                if !inSingleQuote {
                    inDoubleQuote.toggle()
                    if !inDoubleQuote {
                        tokens.append(current)
                        current = ""
                    }
                } else {
                    current.append(char)
                }
            case " ":
                if inSingleQuote || inDoubleQuote {
                    current.append(char)
                } else if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
            default:
                current.append(char)
            }
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }
}
