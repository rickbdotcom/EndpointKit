//
//  File.swift
//  
//
//  Created by rickb on 7/3/21.
//

import Combine
import Foundation

public extension APIClient {
	enum Recover {
		case publisher((APIClient, Error) -> AnyPublisher<Void, Error>)
#if swift(>=5.5)
		case task((APIClient, Error) async throws -> Void)
#endif
	}
}

public extension APIClient.Recover {

#if swift(>=5.5)
	func recoverAsync(_ client: APIClient, _ error: Error) async throws -> Void {
		switch self {
		case let .publisher(recover):
			if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
				try await withUnsafeThrowingContinuation { (c: UnsafeContinuation<Void, Error>) in
					var subscription: AnyCancellable?
					subscription = recover(client, error).sink(receiveCompletion: { result in
						if case let .failure(error) = result {
							c.resume(throwing: error)
							if subscription != nil {
								subscription = nil
							}
						}
					}, receiveValue: {
						c.resume(returning: ())
						if subscription != nil {
							subscription = nil
						}
					})
				}
			} else {
				assertionFailure("how did we get here?")
			}
		case let .task(recover):
			try await recover(client, error)
		}
	}
#endif

	func recoverPublisher(_ client: APIClient, _ error: Error) -> AnyPublisher<Void, Error> {
		switch self {
		case let .publisher(recover):
			return recover(client, error)
#if swift(>=5.5)
		case let .task(recover):
			return Future { promise in
				if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
					async {
						do {
							promise(.success(try await recover(client, error)))
						} catch {
							promise(.failure(error))
						}
					}
				} else {
					promise(.success(()))
				}
			}.eraseToAnyPublisher()
#endif
		}
	}
}
