//
//  URLRequestDataProvider
//
//  Created by Richard Burgess on 6/13/2023
//

import Foundation

/// URLSession implements this, can be used for mocking
public protocol URLRequestDataProvider: Sendable {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

public extension URLRequestDataProvider {

    /// A complete async HTTP request on the specified endpoint
    func request<T: Endpoint>(baseURL: URL, endpoint: T) async throws -> T.Response {
        let request = try await URLRequest(baseURL: baseURL, endpoint: endpoint)
        let (data, response) = try await data(for: request)
        return try await endpoint.responseDecoder.decode(response: response, data: data)
    }
}

public struct AnyURLRequestDataProvider: URLRequestDataProvider {
    let _data: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(_data: @Sendable @escaping (URLRequest) async throws -> (Data, URLResponse)) {
        self._data = _data
    }
    
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await _data(request)
    }
}

public extension URLRequestDataProvider where Self == AnyURLRequestDataProvider {

    static func error(_ error: Error) -> AnyURLRequestDataProvider {
        AnyURLRequestDataProvider { request in
            throw error
        }
    }

    static func response(data: Data?, response: URLResponse?) -> AnyURLRequestDataProvider {
        AnyURLRequestDataProvider { request in
            if let data, let response {
                (data, response)
            } else {
                throw CancellationError()
            }
        }
    }

    static func response(
        data: Data?,
        statusCode: Int = 200,
        httpVersion: String? = nil,
        headerFields: [String : String]? = nil
    ) -> AnyURLRequestDataProvider {
        AnyURLRequestDataProvider { request in
            if let url = request.url,
               let data,
               let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: httpVersion,
                headerFields: headerFields
            ){
                (data, response)
            } else {
                throw CancellationError()
            }
        }
    }

    static func response(
        forResource name: String?,
        extension ext: String? = nil,
        bundle: Bundle = .main,
        statusCode: Int = 200,
        httpVersion: String? = nil,
        headerFields: [String : String]? = nil
    ) -> AnyURLRequestDataProvider {

        AnyURLRequestDataProvider { request in
            if let url = request.url,
               let name,
               let dataURL = bundle.url(forResource: name, withExtension: ext) {
                let data = try Data(contentsOf: dataURL)
                if let response = HTTPURLResponse(
                    url: url,
                    statusCode: statusCode,
                    httpVersion: httpVersion,
                    headerFields: headerFields
                ) {
                    return (data, response)
                }
            }

            throw CancellationError()
        }
    }
}

public struct URLRequestDataProviderCollection: URLRequestDataProvider {
    public struct ProviderMatch: Sendable {
        public let provider: URLRequestDataProvider
        public let handles: @Sendable (URLRequest) -> Bool

        public init(_ provider: URLRequestDataProvider, handles: @Sendable @escaping (URLRequest) -> Bool) {
            self.provider = provider
            self.handles = handles
        }

        public init(_ provider: URLRequestDataProvider, _ path: String) {
            self.provider = provider
            self.handles = {
                $0.url?.path() == path
            }
        }
    }

    public var matches: [ProviderMatch]

    public init(_ matches: [ProviderMatch] = []) {
        self.matches = matches
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        for match in matches {
            if match.handles(request) {
                return try await match.provider.data(for: request)
            }
        }
        throw CancellationError()
    }
}

extension URLRequestDataProviderCollection: EndpointClient {

    public func request<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
        guard let baseURL = URL(string:"endpoint-client://") else {
            throw CancellationError()
        }
        return try await request(baseURL: baseURL, endpoint: endpoint)
    }
}
