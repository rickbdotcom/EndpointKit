//
//  Session.swift
//  
//
//  Created by rickb on 2/2/21.
//

import Combine
import Foundation

extension URLSession {

    func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response: Decodable {
        do {
            return dataTaskPublisher(for:
                try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
            ).debugResponse().validate()
            .tryMap { data, urlResponse in
                try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
            }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters == Void, T.Response: Decodable {
        do {
            return dataTaskPublisher(for:
                try endpoint.endpoint.request(baseURL: baseURL)
            ).debugResponse().validate().tryMap { data, urlResponse in
                try endpoint.endpoint.decoder.decode(T.Response.self, from: data)
            }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<T.Response, Error> where T.Parameters: Encodable, T.Response == Void {
        do {
            return dataTaskPublisher(for:
                try endpoint.endpoint.request(baseURL: baseURL, parameters: endpoint.parameters)
            ).debugResponse().validate()
            .map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func request<T: APIEndpoint>(_ endpoint: T, baseURL: URL) -> AnyPublisher<Void, Error> {
        do {
            return dataTaskPublisher(for:
                try endpoint.endpoint.request(baseURL: baseURL)
            ).debugResponse().validate()
            .map { _ in }.mapError { $0 }.receive(on: RunLoop.main).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

var debugDataTaskPublisherResponse = false

public extension URLSession.DataTaskPublisher {

	func setDebugResponse(_ enable: Bool) {
		debugDataTaskPublisherResponse = enable
	}
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {

    func validate() -> AnyPublisher<Output, Error> {
        tryMap { data, urlResponse in
            if let response = urlResponse as? HTTPURLResponse {
                let statusCode = response.statusCode
                if statusCode < 200 || statusCode > 399 {
                    throw HTTPError(data: data, response: response)
                }
            }
            return (data, urlResponse)
        }.eraseToAnyPublisher()
    }

    func debugResponse() -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data, urlResponse in
            if debugDataTaskPublisherResponse {
                Swift.print(urlResponse.debugDescription)
                if let string = String(data: data, encoding: .utf8) {
                    Swift.print(string)
                }
            }
        }).eraseToAnyPublisher()
    }
}

struct HTTPError: LocalizedError {
    let data: Data
    let response: HTTPURLResponse

    var errorDescription: String? {
        "HTTP Error: \(response.statusCode)"
    }
}
