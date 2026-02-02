---
name: concurrency
description: Swift 6 concurrency patterns. Use when working with async/await, actors, MainActor isolation, or Sendable conformance.
---

# Skill: Concurrency

Guide for Swift 6 concurrency patterns used in this project.

## When to use this skill

- Work with async/await code
- Create actors for thread-safe state
- Understand MainActor isolation
- Fix Sendable conformance issues

---

## Project Configuration

This project uses Swift 6 with special build settings:

| Setting | Value | Effect |
|---------|-------|--------|
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | Automatic Sendable inference |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` | All types MainActor-isolated by default |

---

## Default MainActor Isolation

With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, **all types are MainActor-isolated by default**.

### What this means

- No need for explicit `@MainActor` on ViewModels, Views, or UI-related types
- Types that need to run off the main thread must **opt out** using `nonisolated`

```swift
// These are automatically MainActor-isolated
final class CharacterListViewModel { }  // No @MainActor needed
struct CharacterListView: View { }       // No @MainActor needed
```

---

## Approachable Concurrency (Automatic Sendable)

With `SWIFT_APPROACHABLE_CONCURRENCY = YES`, the compiler **automatically infers `Sendable`** conformance:

```swift
// This struct is automatically Sendable (all properties are Sendable)
struct User: Equatable {
    let id: Int
    let name: String
}

// No need to write:
// struct User: Equatable, Sendable { ... }
```

**Rules:**
- Structs with all Sendable properties are implicitly Sendable
- Enums with Sendable associated values are implicitly Sendable
- Do not explicitly mark types as `Sendable` (it's inferred)

---

## Opting Out of MainActor Isolation

Types that need to run off the main thread must explicitly opt out.

### Actors (custom isolation domain)

Actors have their own isolation domain (not MainActor):

```swift
// Actors are NOT MainActor-isolated
actor CharacterMemoryDataSource {
    private var storage: [Int: CharacterDTO] = [:]

    func save(_ character: CharacterDTO) {
        storage[character.id] = character
    }

    func get(id: Int) -> CharacterDTO? {
        storage[id]
    }
}
```

### Actor-based mocks for thread-safe testing

```swift
// Use actors for mocks that track state across async calls
public actor HTTPTransportMock: HTTPTransportContract {
    public var result: Result<(Data, HTTPURLResponse), Error> = .success((Data(), HTTPURLResponse()))
    public private(set) var sentRequests: [URLRequest] = []

    public init() {}

    // nonisolated to conform to protocol, but uses actor methods internally
    nonisolated public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        await appendRequest(request)
        return try await getResult()
    }

    public func setResult(_ result: Result<(Data, HTTPURLResponse), Error>) {
        self.result = result
    }

    private func appendRequest(_ request: URLRequest) {
        sentRequests.append(request)
    }

    private func getResult() throws -> (Data, HTTPURLResponse) {
        try result.get()
    }
}
```

### nonisolated structs for stateless types

```swift
// Use nonisolated struct for stateless implementations
nonisolated public struct URLSessionTransport: HTTPTransportContract {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPTransportError.invalidResponse
        }
        return (data, httpResponse)
    }
}
```

### UI Test classes

```swift
// XCTestCase subclasses need nonisolated for XCTest compatibility
nonisolated final class CharacterFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCharacterFlow() throws {
        let app = XCUIApplication()
        app.launch()
        // ...
    }
}
```

---

## State Management

Use `@Observable` (iOS 17+), **not** `ObservableObject`:

```swift
// REQUIRED - Use @Observable
@Observable
final class CharacterListViewModel {
    var state: CharacterListViewState = .idle
}

// PROHIBITED - Never use ObservableObject/@Published
final class CharacterListViewModel: ObservableObject {
    @Published var state: CharacterListViewState = .idle
}
```

**Rules:**
- All ViewModels use `@Observable` macro
- No `ObservableObject` protocol conformance
- No `@Published` property wrappers
- Views use `@State` to hold `@Observable` instances

---

## Prohibited Patterns

The following patterns are **prohibited** in this project:

```swift
// PROHIBITED - Never use these patterns
DispatchQueue.main.async { ... }
DispatchQueue.global().async { ... }
completionHandler: @escaping (Result<T, Error>) -> Void
ObservableObject / @Published  // Use @Observable instead
NotificationCenter for async events
Combine for new code
```

---

## Required Patterns

Always use modern Swift concurrency:

```swift
// REQUIRED - Use async/await
func fetchData() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// REQUIRED - Use Task for bridging
Task {
    await performAsyncWork()
}

// REQUIRED - Use actors for shared mutable state
actor DataStore {
    private var cache: [String: Data] = [:]

    func store(_ data: Data, forKey key: String) {
        cache[key] = data
    }
}
```

---

## Common Patterns by Type

| Type | MainActor? | Notes |
|------|------------|-------|
| View | Yes (default) | No annotation needed |
| ViewModel | Yes (default) | No annotation needed |
| UseCase | Yes (default) | No annotation needed |
| Repository | Yes (default) | No annotation needed |
| RemoteDataSource | Yes (default) | Struct, no annotation needed |
| MemoryDataSource | No (actor) | Use `actor` keyword |
| HTTPTransport | nonisolated | Stateless struct, use `nonisolated` |
| HTTPTransportMock | No (actor) | Thread-safe mock with `actor` |
| XCTestCase subclass | nonisolated | Framework requirement |

---

## Checklist

- [ ] Async functions use `async throws` (not completion handlers)
- [ ] Actors are used for shared mutable state
- [ ] No `DispatchQueue` usage
- [ ] No explicit `Sendable` conformance (it's inferred)
- [ ] No explicit `@MainActor` on ViewModels/Views (it's default)
