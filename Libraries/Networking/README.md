# Networking

Native networking layer using **URLSession with async/await**. No external dependencies.

## Overview

This library provides a type-safe HTTP client for making network requests. It uses Swift's modern concurrency features and is fully `Sendable` compliant.

## Components

| File | Description |
|------|-------------|
| `HTTPClientContract.swift` | Protocol defining the HTTP client interface |
| `HTTPClient.swift` | Actor-based implementation using URLSession |
| `Endpoint.swift` | Request configuration (path, method, headers, body) |
| `HTTPMethod.swift` | Supported HTTP methods enum |
| `HTTPError.swift` | Error types for network failures |

## Usage

### Basic Setup

```swift
import ChallengeNetworking

let client = HTTPClient(
	baseURL: URL(string: "https://api.example.com")!,
)
```

### Making Requests

```swift
// Define an endpoint
let endpoint = Endpoint(
	path: "/users",
	method: .get,
	headers: ["Authorization": "Bearer token"],
)

// Request with automatic decoding
let users: [User] = try await client.request(endpoint)

// Request raw data
let data = try await client.request(endpoint)
```

### POST Request with Body

```swift
let user = CreateUserRequest(name: "John", email: "john@example.com")
let body = try JSONEncoder().encode(user)

let endpoint = Endpoint(
	path: "/users",
	method: .post,
	headers: ["Content-Type": "application/json"],
	body: body,
)

let createdUser: User = try await client.request(endpoint)
```

### Query Parameters

```swift
let endpoint = Endpoint(
	path: "/users",
	method: .get,
	queryItems: [
		URLQueryItem(name: "page", value: "1"),
		URLQueryItem(name: "limit", value: "20"),
	],
)
```

## Error Handling

```swift
do {
	let users: [User] = try await client.request(endpoint)
} catch HTTPError.invalidURL {
	// Handle invalid URL
} catch HTTPError.invalidResponse {
	// Handle non-HTTP response
} catch HTTPError.statusCode(let code, let data) {
	// Handle HTTP error status (4xx, 5xx)
	print("HTTP \(code)")
} catch {
	// Handle other errors (network, decoding, etc.)
}
```

## Testing

Use `HTTPClientMock` from `ChallengeNetworkingMocks` for unit testing.

### Basic Test with Given/When/Then

```swift
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeNetworking

@Test
func fetchesUsers() async throws {
	// Given
	let mockData = try JSONEncoder().encode([User(id: 1, name: "Test")])
	let client = HTTPClientMock(result: .success(mockData))

	// When
	let users: [User] = try await client.request(Endpoint(path: "/users"))

	// Then
	#expect(users.count == 1)
	#expect(client.requestedEndpoints.count == 1)
}
```

### Error Testing

```swift
@Test
func handlesError() async {
	// Given
	let client = HTTPClientMock(result: .failure(HTTPError.invalidURL))

	// When / Then
	await #expect(throws: HTTPError.invalidURL) {
		let _: [User] = try await client.request(Endpoint(path: "/users"))
	}
}
```

### Parameterized Tests

```swift
@Test(arguments: [
	HTTPMethod.get,
	HTTPMethod.post,
	HTTPMethod.put,
])
func supportsHTTPMethod(_ method: HTTPMethod) {
	// Given
	let path = "/test"

	// When
	let endpoint = Endpoint(path: path, method: method)

	// Then
	#expect(endpoint.method == method)
}
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Feature Layer                   │
│  (DataSource uses HTTPClientContract)           │
└─────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│              HTTPClientContract                  │
│  (Protocol - enables dependency injection)      │
└─────────────────────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
┌──────────────────┐     ┌──────────────────┐
│   HTTPClient     │     │  HTTPClientMock  │
│   (Production)   │     │    (Testing)     │
└──────────────────┘     └──────────────────┘
```

## Thread Safety

`HTTPClient` is implemented as an `actor`, ensuring thread-safe access to its internal state. All public methods are `async` and can be called from any context.
