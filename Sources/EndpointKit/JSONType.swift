//
//  File.swift
//  EndpointKit
//
//  Created by rickb on 8/6/25.
//

import Foundation

public protocol JSONType: Sendable {
}

extension String: JSONType {
}

extension Int: JSONType {
}

extension Double: JSONType {
}

extension Array: JSONType where Element: JSONType {
}

extension Dictionary: JSONType where Key: JSONType, Value: JSONType {
}
