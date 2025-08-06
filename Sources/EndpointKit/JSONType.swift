//
//  File.swift
//  EndpointKit
//
//  Created by rickb on 8/6/25.
//

import Foundation

public protocol JSONType: Encodable, Sendable {
}

extension String: JSONType {
}

extension Int: JSONType {
}

extension Double: JSONType {
}

extension Array: JSONType where Element: Encodable {
}

extension Dictionary: JSONType where Key: Encodable, Value: Encodable {
}
