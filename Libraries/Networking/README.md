# Networking

Native networking layer using **URLSession with async/await**. No external dependencies.

> **See also:** [HTTPTransport Architecture](../../docs/HTTPTransportArchitecture.md) for design decisions and motivation.

## Overview

This library provides a type-safe HTTP client for making network requests. It uses Swift's modern concurrency features and is fully `Sendable` compliant.

## Components

### HTTP Client

| File | Visibility | Description |
|------|------------|-------------|
| `HTTPClientContract.swift` | **public** | Protocol defining the HTTP client interface |
| `HTTPClient.swift` | **public (open)** | Implementation using HTTPTransportContract |
| `Endpoint.swift` | **public** | Request configuration |
| `HTTPMethod.swift` | **public** | Supported HTTP methods |
| `HTTPError.swift` | **public** | Error types |

### Transport Layer

| File | Visibility | Description |
|------|------------|-------------|
| `HTTPTransportContract.swift` | **public** | Minimal transport abstraction: `URLRequest -> (Data, HTTPURLResponse)` |
| `URLSessionTransport.swift` | **public** | Production implementation using URLSession |
| `HTTPTransportError.swift` | **public** | Transport-level errors |

## Usage

### Basic Setup

```swift
import ChallengeNetworking

guard let baseURL = URL(string: "https://api.example.com") else {
    fatalError("Invalid API base URL")
}

let client = HTTPClient(baseURL: baseURL)
```

### Custom Configuration

```swift
let client = HTTPClient(
    baseURL: baseURL,
    transport: URLSessionTransport(),
    decoder: JSONDecoder()
)
```

### Custom Transport

```swift
// Use a custom transport (e.g., for UI tests)
let client = HTTPClient(
    baseURL: baseURL,
    transport: StubTransport(configuration: config)
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

Use mocks from `ChallengeNetworkingMocks` for unit testing.

### HTTPTransportMock

Thread-safe mock for transport-level testing (actor-based):

```swift
public actor HTTPTransportMock: HTTPTransportContract {
    public private(set) var sentRequests: [URLRequest] = []

    public func setResult(_ result: Result<(Data, HTTPURLResponse), Error>)
    nonisolated public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
```

**Usage:**

```swift
@Test("Loads image from network")
func loadsImage() async throws {
    // Given
    let transport = HTTPTransportMock()
    await transport.setResult(.success((imageData, mockResponse)))
    let sut = CachedImageLoader(transport: transport)

    // When
    let image = await sut.image(for: url)

    // Then
    #expect(image != nil)
    let requests = await transport.sentRequests
    #expect(requests.count == 1)
}
```

### HTTPClientMock

Mock for client-level testing:

```swift
public final class HTTPClientMock: HTTPClientContract {
    // Tracks all requested endpoints for verification
    public private(set) var requestedEndpoints: [Endpoint] = []

    // Configure with success or failure result
    public init(result: Result<Data, Error> = .success(Data()))
}
```

### Basic Test

```swift
import ChallengeNetworkingMocks
import Testing

@Test
func fetchesUsers() async throws {
    // Given
    let mockData = try JSONEncoder().encode([User(id: 1, name: "Test")])
    let sut = HTTPClientMock(result: .success(mockData))

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
    let sut = HTTPClientMock(result: .failure(HTTPError.invalidURL))

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
    let sut = HTTPClientMock(result: .success(Data()))

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
          │
          ▼
┌─────────────────────────────────────────────────┐
│            HTTPTransportContract                 │
│  (Minimal abstraction: URLRequest -> Response)  │
└─────────────────────────────────────────────────┘
                       │
     ┌─────────────────┼─────────────────┐
     ▼                 ▼                 ▼
┌────────────┐  ┌─────────────┐  ┌────────────────┐
│URLSession  │  │  Stub       │  │HTTPTransport   │
│Transport   │  │  Transport  │  │Mock (Testing)  │
│(Production)│  │ (UI Tests)  │  │                │
└────────────┘  └─────────────┘  └────────────────┘
```

**Transport Layer Benefits:**
- Minimal interface: `func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)`
- No URLSession/URLProtocol mocking needed
- Thread-safe testing with actor-based mock
- UI test stubbing via launch arguments (StubTransport in Core module)

## API Reference

### HTTPTransportContract

```swift
public protocol HTTPTransportContract: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
```

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
public enum HTTPMethod: String, Sendable {
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
