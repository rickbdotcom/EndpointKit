//
//  ParameterEncoder.swift
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// A ParameterEncoder modifies a URLRequest by encoding the passed in parameters
public protocol RequestEncoder<Parameters>: Sendable {
    associatedtype Parameters

    func encode(_ parameters: Parameters, into request: URLRequest) async throws -> URLRequest
}
