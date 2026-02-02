# HTTPTransport Architecture - Context and Motivation

## Problem Statement

The project had network mocking complexity that made tests harder to maintain:

### Original Architecture Issues

1. **StubServer for UI Tests**
   - Required running a local HTTP server during UI tests
   - Used dynamic ports to avoid conflicts in parallel test execution
   - Complex setup with request handlers and response matching
   - Fixtures needed `{{BASE_URL}}` placeholder replacement at runtime

2. **URLProtocolMock for Unit Tests**
   - Required mocking at URLSession level via URLProtocol subclass
   - `@unchecked Sendable` and `nonisolated(unsafe)` for thread safety
   - Static request handler made parallel tests tricky
   - Tightly coupled to URLSession internals

3. **Code Duplication**
   - Different mocking strategies for UI tests vs unit tests
   - Similar logic duplicated across Core and Networking modules

## Quinn's Proposal

Apple engineer Quinn's approach: **Don't mock URLSession/URLProtocol directly. Create a smaller abstraction focused on product needs.**

```swift
protocol HTTPTransportContract: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
```

### Benefits
- Minimal interface (single method)
- Easy to implement production version (URLSessionTransport)
- Easy to mock for tests (HTTPTransportMock as actor)
- No URLProtocol complexity
- Thread-safe by design

## Current Implementation

### Architecture

```
┌─────────────────────────────────────────────────┐
│              HTTPClientContract                  │
└─────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│            HTTPTransportContract                 │
│  func send(_ request: URLRequest) async throws  │
│       -> (Data, HTTPURLResponse)                │
└─────────────────────────────────────────────────┘
                       │
     ┌─────────────────┼─────────────────┐
     ▼                 ▼                 ▼
┌────────────┐  ┌─────────────┐  ┌────────────────┐
│URLSession  │  │  Stub       │  │HTTPTransport   │
│Transport   │  │  Transport  │  │Mock            │
│(Production)│  │ (UI Tests)  │  │(Unit Tests)    │
└────────────┘  └─────────────┘  └────────────────┘
```

### Files Created

| File | Location | Purpose |
|------|----------|---------|
| `HTTPTransportContract.swift` | Networking/Sources/Transport/ | Core abstraction |
| `URLSessionTransport.swift` | Networking/Sources/Transport/ | Production impl |
| `HTTPTransportMock.swift` | Networking/Mocks/Transport/ | Actor-based mock for unit tests |
| `StubConfiguration.swift` | Core/Sources/Stub/ | UI test config model |
| `StubTransport.swift` | Core/Sources/Stub/ | UI test transport |
| `StubConfigurationBuilder.swift` | App/Tests/Shared/Stubs/ | Fluent builder for UI tests |

### UI Test Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        TEST PROCESS                              │
│  1. Configure stubConfig with paths and fixtures                 │
│  2. launch() serializes config to JSON Base64 in launchArgs     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         APP PROCESS                              │
│  1. AppContainer detects "--stub-config" in launch arguments    │
│  2. Creates StubTransport with parsed configuration             │
│  3. All HTTP requests go through StubTransport                  │
└─────────────────────────────────────────────────────────────────┘
```

### Usage Example (UI Test)

```swift
@MainActor
func testCharacterListLoads() throws {
    stubConfig
        .stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
        .stub(path: "/api/character*", fixture: "characters_response")

    launch()

    characterList { robot in
        robot.verifyIsVisible()
    }
}
```

### Usage Example (Unit Test)

```swift
@Test("Loads image from network")
func loadsImage() async throws {
    let transport = HTTPTransportMock()
    await transport.setResult(.success((imageData, mockResponse)))
    let sut = CachedImageLoader(transport: transport)

    let image = await sut.image(for: url)

    #expect(image != nil)
}
```

## Complexity Analysis

### What We Gained
- Eliminated StubServer (no local HTTP server)
- Unified mocking approach via HTTPTransportContract
- Thread-safe actor-based mock
- No URLProtocol complexity for most tests
- Fixtures embedded in launch arguments (no file system)

### Remaining Complexity

1. **Two Stub Systems**
   - `HTTPTransportMock` (actor) for unit tests
   - `StubTransport` + `StubConfigurationBuilder` for UI tests
   - Different APIs and patterns

2. **StubConfiguration Serialization**
   - JSON encoding/decoding
   - Base64 for launch arguments
   - Path pattern matching with regex

3. **Module Dependencies**
   - Core depends on Networking (for HTTPTransportContract)
   - StubTransport lives in Core but implements Networking protocol

4. **URLProtocolMock Still Exists**
   - Kept in Networking/Tests for testing URLSessionTransport itself
   - Only use case: verifying the production transport works

## Potential Simplifications to Explore

### Option A: Simplify UI Test Stubbing

Instead of StubTransport with path matching, could we:
- Use a simpler dictionary-based lookup?
- Skip regex pattern matching?
- Embed responses directly without Base64?

### Option B: Unify Mock Approaches

Could HTTPTransportMock serve both unit and UI tests?
- Pass mock instance via environment instead of launch arguments?
- Would require app architecture changes

### Option C: Remove StubTransport Entirely

For UI tests, could we:
- Mock at a higher level (repository/datasource)?
- Use compile-time flags instead of runtime detection?
- Accept real network calls with a test server?

### Option D: Simplify StubConfigurationBuilder

Current builder:
- Loads fixtures from bundle
- Encodes to Base64
- Builds StubConfiguration

Could be simplified to:
- Direct Data passing without Base64?
- Inline JSON strings instead of fixture files?

## Questions for Next Session

1. Is the HTTPTransportContract abstraction worth keeping, or is it over-engineering?
2. Could UI tests work without StubTransport (mocking at a different layer)?
3. Is the launch arguments approach the right way to pass stub config to the app?
4. Should StubConfiguration live in Core or move to a test-only module?

## References

- Quinn's proposal: Use protocol abstraction instead of mocking URLSession
- Swift 6 concurrency: Default MainActor isolation, automatic Sendable inference
- Project settings: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`
