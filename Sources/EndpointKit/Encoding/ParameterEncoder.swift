//
//  ParameterEncoder.swift
//  AmericanCoreNetworking
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// A ParameterEncoder modifies a URLRequest by encoding the passed in parameters
public protocol ParameterEncoder<Parameters> {
    associatedtype Parameters

    func encode(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest
}
