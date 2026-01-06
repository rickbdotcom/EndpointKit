# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

EndpointKit is a type-safe, protocol-oriented Swift networking library that uses declarative, composable patterns similar to SwiftUI. It abstracts HTTP networking into reusable, testable components with full async/await support and Swift concurrency (Sendable) safety.

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests (uses Swift Testing framework, not XCTest)
swift test

# Run tests for a specific target
swift test --filter EndpointKitTests

# Run a specific test
swift test --filter HTTPErrorTests

# Build for release
swift build -c release
```

## Core Architecture

### Central Protocol: `Endpoint`

The `Endpoint` protocol (Sources/EndpointKit/Endpoint.swift) is the foundation of the library:

```swift
protocol Endpoint<Parameters, Response>: Sendable {
    associatedtype Parameters: Sendable
    associatedtype Response: Sendable

    var parameters: Parameters { get }
    var route: Route { get }
    var requestEncoder: any RequestEncoder<Parameters> { get }
    var responseDecoder: any ResponseDecoder<Response> { get }
}
```

### Request/Response Flow

1. **Endpoint Definition** → User defines endpoint with parameters, route, encoder, decoder
2. **URLRequest Construction** → `URLRequest(baseURL:endpoint:)` creates base request
3. **Parameter Encoding** → `RequestEncoder` transforms parameters into URLRequest
4. **Modifier Application** → Modifiers intercept and transform the pipeline
5. **Network Execution** → `URLRequestDataProvider` (typically URLSession) executes request
6. **Response Decoding** → `ResponseDecoder` transforms raw response into typed response

Key orchestration happens in `URLRequestDataProvider.request()` (Sources/EndpointKit/URLRequestDataProvider.swift).

### Smart Defaults System

The library uses protocol extensions (EndpointDefaults.swift) to provide intelligent defaults based on type constraints:

- `Parameters == Void` → `EmptyParameterEncoder`
- `Parameters: Encodable` → `JSONEncodableParameterEncoder` (or `URLParameterEncoder` for GET)
- `Parameters == Data` → `DataParameterEncoder`
- `Response: Decodable` → `JSONDecodableResponseDecoder` with HTTP validation
- `Response == Void` → `EmptyResponseDecoder` with HTTP validation

This means users rarely need to explicitly implement encoders/decoders.

### The Modifier System

The modifier system is the primary extension point, following functional composition similar to SwiftUI:

#### Three Modifier Types:

1. **RequestModifier** (Modifiers/RequestModifier.swift)
   - Wraps `RequestEncoder` to intercept parameter encoding
   - Use for: Adding headers, changing timeout, modifying URL

2. **ResponseModifier** (Modifiers/ResponseModifier.swift)
   - Wraps `ResponseDecoder` to intercept response decoding
   - Use for: HTTP validation, custom error handling, response mapping

3. **URLRequestModifier** (Modifiers/URLRequestModifier.swift)
   - Direct `URLRequest` transformation after encoding but before execution
   - Bridges to RequestModifier via `asRequestModifier()`

#### Built-in Modifiers (Modifiers/EndpointModifiers.swift):

- `.merge(headers:)` / `.remove(headers:)` - Header manipulation
- `.authorize(with:)` - Authorization (Bearer, Basic)
- `.cachePolicy()` - URLRequest cache policy
- `.timeout()` - Request timeout
- `.contentType()` - Content-Type header
- `.validateHTTP()` - HTTP status code validation
- `.validate(error:)` - Custom error decoding
- `.replaceError()` - Error recovery
- `.map()` / `.mapURLComponents()` - URL transformation

#### Modifier Composition:

```swift
endpoint
    .modify(.merge(headers: ["X-API-Key": "abc"]))
    .modify(.timeout(120))
    .modify(.validateHTTP())
```

Modifiers always return `AnyEndpoint<Parameters, Response>` for type erasure and composition.

### Type Erasure Pattern

The library uses type erasure extensively for flexibility:

- `AnyEndpoint` - Type-erased endpoint
- `AnyRequestEncoder` - Type-erased request encoder
- `AnyResponseDecoder` - Type-erased response decoder
- `AnyEndpointModifier` - Type-erased modifier

This pattern is critical for modifier chaining and storing heterogeneous collections.

### Testing Architecture

- Uses Swift Testing framework (not XCTest) - note `import Testing` and `@Test` attributes
- `URLRequestDataProvider` protocol enables mocking/testing without real network calls
- `AnyURLRequestDataProvider` provides type-erased test implementations
- `URLRequestDataProviderCollection` enables path-based routing for test scenarios
- Test utilities in Tests/EndpointKitTests/TestUtils.swift

When writing tests, use parameterized tests with `@Test(arguments: [...])` pattern.

## Key Files & Locations

### Core Protocols
- `Sources/EndpointKit/Endpoint.swift` - Central protocol
- `Sources/EndpointKit/RequestEncoder.swift` - Parameter encoding
- `Sources/EndpointKit/ResponseDecoder.swift` - Response decoding
- `Sources/EndpointKit/URLRequestDataProvider.swift` - Network abstraction

### Modifiers
- `Sources/EndpointKit/Modifiers/EndpointModifier.swift` - Modifier protocol
- `Sources/EndpointKit/Modifiers/RequestModifier.swift` - Request pipeline
- `Sources/EndpointKit/Modifiers/ResponseModifier.swift` - Response pipeline
- `Sources/EndpointKit/Modifiers/URLRequestModifier.swift` - Direct URLRequest transformation

### Defaults & Utilities
- `Sources/EndpointKit/EndpointDefaults.swift` - Smart defaults implementation
- `Sources/EndpointKit/AnyEndpoint.swift` - Type erasure for endpoints
- `Sources/EndpointKit/Route.swift` - HTTP method + path
- `Sources/EndpointKit/HTTPError.swift` - Error handling
- `Sources/EndpointKit/cURL.swift` - Debug utility for cURL conversion

### Encoders (Sources/EndpointKit/Encoders/)
- JSONEncodableParameterEncoder, URLParameterEncoder, FormParameterEncoder, DataParameterEncoder, EmptyParameterEncoder

### Decoders (Sources/EndpointKit/Decoders/)
- JSONDecodableResponseDecoder, DataResponseDecoder, StringResponseDecoder, EmptyResponseDecoder

## Development Patterns

### When Adding New Modifiers

1. Decide on modifier type (RequestModifier, ResponseModifier, or URLRequestModifier)
2. Implement as extension on `AnyEndpointModifier` with static factory method
3. Follow naming convention: `.verbNoun()` (e.g., `.merge(headers:)`, `.validateHTTP()`)
4. Always ensure Sendable conformance for concurrency safety
5. Return `AnyEndpointModifier<Parameters, Response>` for composability

### When Adding Encoders/Decoders

1. Conform to `RequestEncoder` or `ResponseDecoder` protocol
2. Implement async `encode()` or `decode()` method
3. Add type-erased wrapper (AnyRequestEncoder/AnyResponseDecoder)
4. Consider adding default implementation in EndpointDefaults.swift if applicable
5. Ensure Sendable conformance

### When Extending Core Protocols

- Extensions on `Endpoint` go in Endpoint.swift or relevant modifier files
- Keep type constraints clear and specific
- Maintain consistency with existing API patterns
- All public APIs must be fully async/await compatible and Sendable
