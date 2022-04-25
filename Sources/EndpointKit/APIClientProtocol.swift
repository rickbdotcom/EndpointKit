//
//  File.swift
//  
//
//  Created by RICHARD BURGESS on 4/24/22.
//

import Foundation

public protocol APIClientProtocol {
	func request<T: APIEndpoint>(_ endpoint: T) async throws -> T.Response
}
