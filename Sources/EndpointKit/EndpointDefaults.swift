//
//  EndpointDefault.swift
//  
//
//  Created by Burgess, Rick on 8/25/23.
//

import Foundation

public extension Endpoint where Parameters == Void {
    var requestEncoder: any RequestEncoder<Parameters> {
        EmptyParameterEncoder()
    }
}

public extension Endpoint where Parameters: Encodable {
    var requestEncoder: any RequestEncoder<Parameters> {
        route.method == .get ? URLParameterEncoder() : JSONEncodableParameterEncoder()
    }
}

public extension Endpoint where Parameters == Data {
    var requestEncoder: any RequestEncoder<Parameters> {
        DataParameterEncoder()
    }
}

public extension Endpoint where Response == Void {
    var responseDecoder: any ResponseDecoder<Response> {
        EmptyResponseDecoder().validateHTTP()
    }
}

public extension Endpoint where Response: Decodable {
    var responseDecoder: any ResponseDecoder<Response> {
        JSONDecodableResponseDecoder().validateHTTP()
    }
}

public extension Endpoint where Response == Data {
    var responseDecoder: any ResponseDecoder<Response> {
        DataResponseDecoder().validateHTTP()
    }
}

public extension Endpoint where Response == String {
    var responseDecoder: any ResponseDecoder<Response> {
        StringResponseDecoder().validateHTTP()
    }
}
