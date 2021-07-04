//
//  URL.swift
//  
//
//  Created by rickb on 2/4/21.
//

import Foundation

extension URL: ExpressibleByStringLiteral {

	public init(stringLiteral: StaticString) {
		guard let url = URL(string: "\(stringLiteral)") else {
			preconditionFailure("Invalid static URL string: \(stringLiteral)")
		}
		self = url
	}
}
