# Networking

Native networking layer using **URLSession with async/await**. No external dependencies.

## Overview

This library provides a type-safe HTTP client (REST) and GraphQL client for making network requests. It uses Swift's modern concurrency features and is fully `Sendable` compliant.

## Components

### HTTP (REST)

| File | Visibility | Description |
|------|------------|-------------|
| `HTTPClientContract.swift` | **public** | Protocol defining the HTTP client interface |
| `HTTPClient.swift` | **public** | Implementation using URLSession |
| `Endpoint.swift` | **public** | Request configuration |
| `HTTPMethod.swift` | **public** | Supported HTTP methods |
| `HTTPError.swift` | **public** | HTTP error types |
| `HTTPErrorMapper.swift` | **public** | Maps `HTTPError` to `APIError` |

### GraphQL

| File | Visibility | Description |
|------|------------|-------------|
| `GraphQLClientContract.swift` | **public** | Protocol defining the GraphQL client interface |
| `GraphQLClient.swift` | **public** | Implementation using HTTPClient |
| `GraphQLOperation.swift` | **public** | Query/mutation with variables |
| `GraphQLVariable.swift` | **public** | Type-safe GraphQL variable values |
| `GraphQLError.swift` | **public** | GraphQL-specific error types |
| `GraphQLErrorMapper.swift` | **public** | Maps `GraphQLError` to `APIError` |
| `GraphQLResponse.swift` | **public** | Generic response wrapper |
| `GraphQLResponseError.swift` | **public** | Individual error from GraphQL response |

### API

| File | Visibility | Description |
|------|------------|-------------|
| `APIError.swift` | **public** | API-agnostic error types (used by DataSources and error mappers) |

## Usage

### Basic Setup

```swift
import ChallengeNetworking

guard let baseURL = URL(string: "https://api.example.com") else {
    preconditionFailure("Invalid API base URL")
}

let client = HTTPClient(baseURL: baseURL)
```

### Custom Configuration

```swift
let client = HTTPClient(
    baseURL: baseURL,
    session: .shared,
    decoder: JSONDecoder()
)
```

### Making Requests

```swift
// Define an endpoint
let endpoint = Endpoint(
    path: "/users",
    method: .get,
    headers: ["Authorization": "Bearer token"]
)

// Request with automatic decoding
let users: [User] = try await client.request(endpoint)

// Request raw data
let data: Data = try await client.request(endpoint)
```

### POST Request with Body

```swift
let user = CreateUserRequest(name: "John", email: "john@example.com")
let body = try JSONEncoder().encode(user)

let endpoint = Endpoint(
    path: "/users",
    method: .post,
    headers: ["Content-Type": "application/json"],
    body: body
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
        URLQueryItem(name: "limit", value: "20")
    ]
)
```

## Error Handling

```swift
do {
    let users: [User] = try await client.request(endpoint)
} catch HTTPError.invalidURL {
    // Handle invalid URL construction
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

### HTTPClientMock

```swift
public final class HTTPClientMock: HTTPClientContract {
    // Tracks all requested endpoints for verification
    public private(set) var requestedEndpoints: [Endpoint] = []

    // Configure result after init
    public var result: Result<Data, Error> = .success(Data())

    public init() {}
}
```

Also available: `GraphQLClientMock` for testing GraphQL data sources.

### Basic Test

```swift
import ChallengeNetworkingMocks
import Testing

@Test
func fetchesUsers() async throws {
    // Given
    let mockData = try JSONEncoder().encode([User(id: 1, name: "Test")])
    let sut = HTTPClientMock()
    sut.result = .success(mockData)

    // When
    let users: [User] = try await sut.request(Endpoint(path: "/users"))

    // Then
    #expect(users.count == 1)
    #expect(sut.requestedEndpoints.count == 1)
}
```

### Error Testing

```swift
@Test
func handlesError() async {
    // Given
    let sut = HTTPClientMock()
    sut.result = .failure(HTTPError.invalidURL)

    // When / Then
    await #expect(throws: HTTPError.invalidURL) {
        let _: [User] = try await sut.request(Endpoint(path: "/users"))
    }
}
```

### Verifying Endpoint Configuration

```swift
@Test
func sendsCorrectEndpoint() async throws {
    // Given
    let sut = HTTPClientMock()

    // When
    let _: Data = try await sut.request(Endpoint(
        path: "/users",
        method: .post,
        headers: ["Authorization": "Bearer token"]
    ))

    // Then
    let endpoint = try #require(sut.requestedEndpoints.first)
    #expect(endpoint.path == "/users")
    #expect(endpoint.method == .post)
    #expect(endpoint.headers["Authorization"] == "Bearer token")
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

## API Reference

### HTTPClientContract

```swift
public protocol HTTPClientContract: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}
```

### Endpoint

```swift
public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryItems: [URLQueryItem]?
    public let body: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    )
}
```

### HTTPMethod

```swift
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
```

### HTTPError

```swift
public enum HTTPError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case statusCode(Int, Data)
}
```
