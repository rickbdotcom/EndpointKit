//
//  APIClient.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Combine
import Foundation

public class APIClient: ObservableObject {
	@Published public var session: URLSession

	public typealias MapAPIError = (HTTPURLResponse, Data) -> Error?

	let baseURL: URL
	let mapApiError: MapAPIError?
	let recover: Recover?

	public init(baseURL: URL, session: URLSession = URLSession(configuration: .default), mapApiError: MapAPIError? = nil, recover: Recover? = nil) {
		self.baseURL = baseURL
		self.session = session
		self.mapApiError = mapApiError
		self.recover = recover
	}
}
