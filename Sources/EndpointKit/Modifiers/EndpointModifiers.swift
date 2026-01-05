//
//  EndpointModifiers.swift
//  backoff
//
//  Created by Richard Burgess on 1/2/26.
//

import Foundation

public protocol EndpointModifiers {
    func modifiers<T: Endpoint>(for endpoint: T) -> [AnyEndpointModifier<T.Parameters, T.Response>] 
}

public extension EndpointModifiers where Self == EndpointModifiersArray {
    
    static func array(_ array: [any EndpointModifiers]) -> Self {
        .init(array: array)
    }
}

public struct EndpointModifiersArray: EndpointModifiers {
    let array: [EndpointModifiers]

    public func modifiers<T: Endpoint>(for endpoint: T) -> [AnyEndpointModifier<T.Parameters, T.Response>] {
        array.flatMap { $0.modifiers(for: endpoint) }
    }
}
