//
//  Combine.swift
//  
//
//  Created by rickb on 2/5/21.
//

import Combine
import Foundation

extension Publishers {

    static func doCatch<P: Publisher>(_ block: (() throws -> P)) -> AnyPublisher<P.Output, Error> {
        do {
			return (try block()).mapError().eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

extension Publisher {

	func tryFlatMap<P: Publisher>(_ block: @escaping (Output) throws -> P) -> AnyPublisher<P.Output, Error> {
		mapError().flatMap { output in
			Publishers.doCatch {
				try block(output)
			}
		}.eraseToAnyPublisher()
	}

	func mapError() -> AnyPublisher<Output, Error> {
		mapError { $0 as Error }.eraseToAnyPublisher()
	}
}
