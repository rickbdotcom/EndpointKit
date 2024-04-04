//
//  APIEndpointDefault.swift
//  
//
//  Created by Burgess, Rick on 8/25/23.
//

import Foundation

public extension APIEndpoint where Parameters == Void {
    var parameterEncoder: any ParameterEncoder<Parameters> {
        EmptyParameterEncoder()
    }
}

public extension APIEndpoint where Parameters: Encodable {
    var parameterEncoder: any ParameterEncoder<Parameters> {
        endpoint.method == .get ? URLParameterEncoder() : JSONEncodableParameterEncoder()
    }
}

public extension APIEndpoint where Parameters == Data {
    var parameterEncoder: any ParameterEncoder<Parameters> {
        DataParameterEncoder()
    }
}

public extension APIEndpoint where Response == Void {
    var responseDecoder: any ResponseDecoder<Response> {
        EmptyResponseDecoder().validateHTTP()
    }
}

public extension APIEndpoint where Response: Decodable {
    var responseDecoder: any ResponseDecoder<Response> {
        JSONDecodableResponseDecoder().validateHTTP()
    }
}

public extension APIEndpoint where Response == Data {
    var responseDecoder: any ResponseDecoder<Response> {
        DataResponseDecoder().validateHTTP()
    }
}

public extension APIEndpoint where Response == String {
    var responseDecoder: any ResponseDecoder<Response> {
        StringResponseDecoder().validateHTTP()
    }
}
