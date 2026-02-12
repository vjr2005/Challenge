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

### Framework subclasses called from background threads

```swift
// URLProtocol subclasses are called from background threads
final class URLProtocolMock: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

    nonisolated override init(
        request: URLRequest,
        cachedResponse: CachedURLResponse?,
        client: (any URLProtocolClient)?
    ) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    nonisolated override class func canInit(with request: URLRequest) -> Bool { true }
    nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    nonisolated override func startLoading() { /* ... */ }
    nonisolated override func stopLoading() {}
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
- Stateful ViewModels use `@Observable` macro (stateless ViewModels with no observable state are plain `final class`)
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
| URLProtocol subclass | nonisolated | Framework requirement |
| XCTestCase subclass | nonisolated | Framework requirement |

---

## Actor Reentrancy

> **Reference:** [SE-0306 — Actors](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md#actor-reentrancy)

Swift actors are **reentrant by design**. When an actor-isolated function suspends at an `await`, other tasks can execute on the same actor before the original function resumes. This is called **interleaving**.

### The problem

Every `await` inside an actor is a **suspension point** where actor state can change:

```swift
// DANGEROUS — reentrancy can break invariants
actor ImageDiskCache {
    private let fileSystem: FileSystemContract // `: Actor`

    func image(for url: URL) async -> UIImage? {
        guard let data = try? await fileSystem.contents(at: fileURL) else {
            return nil
        }
        // ⚠️ SUSPENSION POINT — another task can run here (e.g., eviction deletes the file)
        guard let attributes = try? await fileSystem.fileAttributes(at: fileURL) else {
            // File was deleted between the two awaits!
            return nil
        }
        // ...
    }
}
```

Between two `await` calls on the same actor, another task (e.g., eviction) can interleave and modify the actor's state or the underlying filesystem. This leads to:
- **Stale reads**: data read before suspension may not match state after resumption
- **Broken invariants**: multi-step operations are no longer atomic
- **Redundant or conflicting operations**: concurrent evictions interleaving

### The solution: eliminate suspension points

If an actor's dependency is `Sendable` with `nonisolated` methods instead of an `Actor`, its calls execute **synchronously** within the caller actor's isolation — no `await`, no suspension, no interleaving:

```swift
// SAFE — zero suspension points, every method is an atomic critical section
protocol FileSystemContract: Sendable {
    nonisolated func contents(at url: URL) throws -> Data
    nonisolated func write(_ data: Data, to url: URL) throws
    // ...
}

struct FileSystem: FileSystemContract {
    // FileManager is not Sendable but is documented as thread-safe.
    // Safe to use from any isolation domain without synchronization.
    nonisolated(unsafe) private let fileManager: FileManager

    nonisolated func contents(at url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
    // ...
}

actor ImageDiskCache {
    private let fileSystem: FileSystemContract

    func image(for url: URL) -> UIImage? { // No `async` — fully synchronous
        guard let data = try? fileSystem.contents(at: fileURL) else { return nil }
        // No suspension point — no other task can interleave here
        guard let attributes = try? fileSystem.fileAttributes(at: fileURL) else { ... }
        // ...
    }
}
```

### When to use each pattern

| Pattern | Use when | Example |
|---------|----------|---------|
| `: Actor` protocol | Dependency has its **own mutable state** to protect | `MemoryDataSource`, `UserDefaultsDataSource` |
| `: Sendable` + `nonisolated` | Dependency is a **stateless wrapper** around a thread-safe API | `FileSystem` (wraps `FileManager`) |

### `nonisolated` is mandatory on protocol methods

With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, protocol methods **without** `nonisolated` are MainActor-isolated by default. Calling them from a non-MainActor actor requires `await` for the MainActor hop — reintroducing suspension points.

`nonisolated(unsafe)` on the **property** does NOT bypass method isolation — it only affects property access:

```swift
actor ImageDiskCache {
    nonisolated(unsafe) private let fileSystem: FileSystemContract
    // ❌ fileSystem.contents(at:) is still MainActor-isolated per protocol
    // ❌ Compiler error: "Call to main actor-isolated instance method in a synchronous actor-isolated context"
}
```

### Thread-safe non-Sendable types

`FileManager` and `UserDefaults` are thread-safe but not `Sendable`. Use `nonisolated(unsafe)` to store them:

```swift
struct FileSystem: FileSystemContract {
    // FileManager is not Sendable but is documented as thread-safe.
    // Safe to use from any isolation domain without synchronization.
    nonisolated(unsafe) private let fileManager: FileManager
}
```

### Mock pattern for Sendable protocols with nonisolated methods

```swift
final class FileSystemMock: FileSystemContract, @unchecked Sendable {
    nonisolated(unsafe) var files: [URL: Data] = [:]
    nonisolated(unsafe) var writeError: (any Error)?
    nonisolated(unsafe) private(set) var writeCallCount = 0

    @MainActor init() {}

    nonisolated func write(_ data: Data, to url: URL) throws {
        writeCallCount += 1
        if let writeError { throw writeError }
        files[url] = data
    }
}
```

This is safe in practice because the actor serializes all calls to the mock. Tests configure the mock on MainActor (setup) and verify on MainActor (assertions) — no concurrent access.

---

## Checklist

- [ ] Async functions use `async throws` (not completion handlers)
- [ ] Actors are used for shared mutable state
- [ ] No `DispatchQueue` usage
- [ ] No explicit `Sendable` conformance (it's inferred)
- [ ] No explicit `@MainActor` on ViewModels/Views (it's default)
- [ ] Actor methods with multiple `await` calls reviewed for reentrancy risks
- [ ] Stateless wrappers around thread-safe APIs use `: Sendable` + `nonisolated` (not `: Actor`)
