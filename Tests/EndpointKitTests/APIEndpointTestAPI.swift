//
//  File.swift
//
//
//  Created by Burgess, Rick on 4/4/24.
//

import Foundation
import XCTest
@testable import EndpointKit

protocol CustomErrorProtocol {
}

enum API {
    struct Login: Endpoint {
        struct Parameters: Codable, Equatable {
            let username: String
            let password: String
        }

        struct Response: Decodable, Equatable {
            let accessToken: String
            let refreshToken: String
        }
        let route = POST("login")

        let parameters: Parameters
    }

    struct Track: Endpoint {
        struct Parameters: Encodable {
            let action: String
        }
        typealias Response = Void

        let route = GET("track")

        let parameters: Parameters

        var responseDecoder: any ResponseDecoder<Response> {
            EmptyResponseDecoder()
                .validateHTTP()
                .validate(error: CustomError.self)
        }
    }

    struct CustomError: Error, Decodable {
        let errorCode: Int
    }

    struct Form: Endpoint {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }
        typealias Response = String

        let route = POST("form")

        let parameters: Parameters

        var requestEncoder: any RequestEncoder<Parameters> {
            FormParameterEncoder()
        }
    }

    struct Poll: Endpoint {
        typealias Parameters = [String: any Sendable]
        typealias Response = [String: Int]

        let pollId: String

        var route: Route { POST("poll/\(pollId)") }

        let parameters: Parameters

        var requestEncoder: any RequestEncoder<Parameters> {
            SerializedJSONParameterEncoder()
                .contentType("application/vnd.aa.mobile.app+json;version=50.0")
        }
        var responseDecoder: any ResponseDecoder<Response> {
            SerializedJSONResponseDecoder()
        }
    }

    struct ImageUpload: Endpoint {
        typealias Parameters = Data
        typealias Response = Void

        let route = POST("upload")

        let parameters: Parameters
    }

    struct ImageDownload: Endpoint {
        typealias Response = Data

        let route = GET("download")
    }

    struct GetStuff: Endpoint, CustomErrorProtocol {
        typealias Parameters = Void
        typealias Response = Void
        
        let route = GET("getstuff")
    }

    static let baseURL = URL(string: "https://www.rickb.com")!

    static let headers = ["pageName": "home"]
}
