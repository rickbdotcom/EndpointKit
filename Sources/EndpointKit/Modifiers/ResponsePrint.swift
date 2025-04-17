//
//  File.swift
//  EndpointKit
//
//  Created by Burgess, Rick (CHICO-C) on 4/17/25.
//

import Foundation

extension AnyEndpointModifier {

    public static func printResponse() -> Self {
        ResponseModifier {
            $0.print()
        }.any()
    }
}

extension ResponseDecoder {

    public func print() -> any ResponseDecoder<Response> {
        AnyResponseDecoder { response, data in
            Swift.print(response)
            
            if let string = String(data: data, encoding: .utf8) {
                Swift.print(string)
            }
            return try await decode(response: response, data: data)
        }
    }
}
