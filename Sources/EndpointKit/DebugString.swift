//
//  File.swift
//  EndpointKit
//
//  Created by Richard Burgess on 12/11/25.
//

import Foundation

public extension URLRequest {

    func logString() -> String {
        var lines: [String?] = []

        lines.append("\(httpMethod ?? "") \(url?.pathQuery() ?? "")")
        lines.append(logStringHeaders(allHTTPHeaderFields))
        lines.append(httpBody?.logString())
        
        return lines.compactMap { $0 }.joined(separator: "\n")
    }
}

public func logString(data: Data, response: URLResponse) -> String {
    var lines: [String?] = []
    guard let response = response as? HTTPURLResponse else {
        return ""
    }
    lines.append("HTTP \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
    lines.append(logStringHeaders(response.allHeaderFields))
    lines.append(data.logString())
    
    return lines.compactMap { $0 }.joined(separator: "\n")
}

private extension String {
    
    init(logData: Data) {
        if let string = String(data: logData, encoding: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: logData), 
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self = jsonString
            } else {
                self = string
            }
        } else {
            self = logData.map { String(format: "\\x%02X", $0) }.joined()
        }
    }
}

private extension Data {

    func logString() -> String {
        String(logData: self)
    }
}

private extension URL {

    func pathQuery() -> String {
        [path(percentEncoded: false), query(percentEncoded: false)].compactMap { $0 }.joined(separator: "?")
    }
}

private func logStringHeaders(_ headers: [AnyHashable: Any]?) -> String? {
    guard let headers else {
        return nil
    }
    return headers.compactMap {
        if let key = $0.0 as? String, 
           let value = $0.1 as? String {
           (key, value) 
        } else {
            nil
        }
    }.sorted {
        $0.0 < $1.0
    }.map {
        "\($0): \($1)"
    }.joined(separator: "\n")
}
