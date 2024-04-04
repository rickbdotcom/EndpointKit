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
    struct Login: APIEndpoint {
        struct Parameters: Codable, Equatable {
            let username: String
            let password: String
        }

        struct Response: Decodable, Equatable {
            let accessToken: String
            let refreshToken: String
        }
        let endpoint = POST("login")

        let parameters: Parameters
    }

    struct Track: APIEndpoint {
        struct Parameters: Encodable {
            let action: String
        }
        typealias Response = Void

        let endpoint = GET("track")

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

    struct Form: APIEndpoint {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }
        typealias Response = String

        let endpoint = POST("form")

        let parameters: Parameters

        var parameterEncoder: any ParameterEncoder<Parameters> {
            FormParameterEncoder()
        }
    }

    struct Poll: APIEndpoint {
        typealias Parameters = [String: Any]
        typealias Response = [String: Int]

        let pollId: String

        var endpoint: Endpoint { POST("poll/\(pollId)") }

        let parameters: Parameters

        var parameterEncoder: any ParameterEncoder<Parameters> {
            SerializedJSONParameterEncoder()
                .contentType("application/vnd.aa.mobile.app+json;version=50.0")
        }
        var responseDecoder: any ResponseDecoder<Response> {
            SerializedJSONResponseDecoder()
        }
    }

    struct ImageUpload: APIEndpoint {
        typealias Parameters = Data
        typealias Response = Void

        let endpoint = POST("upload")

        let parameters: Parameters
    }

    struct ImageDownload: APIEndpoint {
        typealias Response = Data

        let endpoint = GET("download")
    }

    struct GetStuff: APIEndpoint, CustomErrorProtocol {
        typealias Parameters = Void
        typealias Response = Void
        
        let endpoint = GET("getstuff")
    }

    static let baseURL = URL(string: "https://www.rickb.com")!

    static let headers = ["pageName": "home"]
}
