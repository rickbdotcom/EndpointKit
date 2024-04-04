//
//  HTTPMethod.swift
//
//  Created by Richard Burgess on 6/13/2023
//
import Foundation

/// Enum representing defined HTTP method types
public struct HTTPMethod: Hashable, Equatable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let head = HTTPMethod(rawValue: "HEAD")
    public static let patch = HTTPMethod(rawValue: "PATCH")
}
