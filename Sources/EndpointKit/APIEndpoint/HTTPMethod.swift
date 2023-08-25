//
//  HTTPMethod.swift
//  
//
//  Created by Richard Burgess on 6/13/2023
//
import Foundation

/// Enum representing defined HTTP method types
public enum HTTPMethod: String, Equatable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
}
