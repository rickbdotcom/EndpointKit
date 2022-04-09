// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "EndpointKit",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "EndpointKit",
			targets: ["EndpointKit"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "EndpointKit",
			dependencies: []),
		.testTarget(
			name: "EndpointKitTests",
			dependencies: ["EndpointKit"]),
	]
)
