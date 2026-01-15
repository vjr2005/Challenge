# Project Guidelines

This document defines the coding standards, architecture patterns, and development practices for this iOS project. All code and documentation must be written in **English**.

> **CRITICAL:** All generated code must compile without errors or warnings. Before writing code, carefully analyze for:
> - Unused variables, parameters, or imports
> - Missing protocol conformances
> - Type mismatches
> - Concurrency issues (Sendable, actor isolation)
> - Implicit returns where explicit are needed
> - **Never use force unwrap (`!`)** - use `guard let`, `if let`, or `try?` instead

## Table of Contents

- [Swift Version and Concurrency](#swift-version-and-concurrency)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Networking](#networking)
- [Testing](#testing)
- [Style Guide](#style-guide)
- [Tuist Configuration](#tuist-configuration)
- [Skills Reference](#skills-reference)

---

## Swift Version and Concurrency

### Requirements

- **Swift 6** with:
  - `SWIFT_APPROACHABLE_CONCURRENCY = YES` (inferencia mejorada)
  - `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (aislamiento por defecto)
- **iOS 16.0+** minimum deployment target
- **SwiftUI** as the primary UI framework

### Approachable Concurrency

This project uses Swift 6's Approachable Concurrency mode, which provides:

- **Default MainActor isolation** - Types are MainActor-isolated by default
- **Improved Sendable inference** - Less explicit `Sendable` annotations needed
- **Flexible closures** - Fewer restrictions on closures crossing isolation boundaries

### Concurrency Rules

All asynchronous code must use modern Swift concurrency. The following patterns are **prohibited**:

```swift
// PROHIBITED - Never use these patterns
DispatchQueue.main.async { ... }
DispatchQueue.global().async { ... }
completionHandler: @escaping (Result<T, Error>) -> Void
```

Instead, always use:

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

### Actor Isolation

Respect isolation domains when crossing boundaries:

```swift
// MainActor for UI updates
@MainActor
final class ViewModel: ObservableObject {
  @Published var items: [Item] = []

  func loadItems() async {
    let fetchedItems = await repository.fetchItems()
    items = fetchedItems // Safe: already on MainActor
  }
}

// Custom actors for specific domains
actor NetworkManager {
  func request(_ endpoint: Endpoint) async throws -> Data {
    // Network operations isolated to this actor
  }
}
```

### Opting Out of MainActor Isolation

With `MainActor` as the default isolation, types that need to run off the main thread must explicitly opt out using `nonisolated`. Common cases:

#### DTOs used with actors

DTOs that will be stored or processed by actors must be marked as `nonisolated`:

```swift
// DTOs need nonisolated to be used inside actors (e.g., MemoryDataSource)
nonisolated struct CharacterDTO: Decodable, Equatable {
	let id: Int
	let name: String
}

// Then they can be safely used inside actors
actor CharacterMemoryDataSource {
	private var storage: [Int: CharacterDTO] = [:]

	func save(_ character: CharacterDTO) {
		storage[character.id] = character  // No isolation error
	}
}
```

#### Framework subclasses called from background threads

```swift
// URLProtocol subclasses are called from background threads by the URL loading system
final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

	// Must override init with nonisolated
	nonisolated override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	nonisolated override class func canInit(with request: URLRequest) -> Bool {
		true
	}

	nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	nonisolated override func startLoading() {
		// Implementation
	}

	nonisolated override func stopLoading() {}
}
```

### Sendable Conformance

Ensure types crossing isolation boundaries conform to `Sendable`:

```swift
// Value types are implicitly Sendable if all properties are Sendable
struct User: Sendable {
  let id: UUID
  let name: String
}

// Use @MainActor for mutable classes that need to be Sendable
@MainActor
final class AppState: ObservableObject, Sendable {
  @Published var isLoggedIn = false
}
```

---

## Architecture

This project follows **MVVM + Clean Architecture + Coordinators** pattern without external dependencies.

### Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    View     │  │  ViewModel  │  │    Coordinator      │  │
│  │  (SwiftUI)  │◄─┤ @MainActor  │◄─┤  (Navigation)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │      Use Case       │  │         Models              │   │
│  │  (Business Logic)   │  │    (Domain Models)          │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │     Repository      │  │       Data Source           │   │
│  │  (Implementation)   │  │   (Remote/Local/Mock)       │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### View (SwiftUI)

Views are pure UI components with no business logic:

```swift
struct UserListView: View {
  @StateObject private var viewModel: UserListViewModel

  var body: some View {
    List(viewModel.users) { user in
      UserRowView(user: user)
        .onTapGesture {
          viewModel.didSelectUser(user)
        }
    }
    .task {
      await viewModel.loadUsers()
    }
  }
}
```

### ViewModel

ViewModels manage state and coordinate between View and Use Cases:

```swift
@MainActor
final class UserListViewModel: ObservableObject {
  @Published private(set) var users: [User] = []
  @Published private(set) var isLoading = false
  @Published private(set) var error: Error?

  private let getUsersUseCase: GetUsersUseCaseContract
  private weak var coordinator: UserCoordinator?

  init(
    getUsersUseCase: GetUsersUseCaseContract,
    coordinator: UserCoordinator?
  ) {
    self.getUsersUseCase = getUsersUseCase
    self.coordinator = coordinator
  }

  func loadUsers() async {
    isLoading = true
    defer { isLoading = false }

    do {
      users = try await getUsersUseCase.execute()
    } catch {
      self.error = error
    }
  }

  func didSelectUser(_ user: User) {
    coordinator?.showUserDetail(user)
  }
}
```

### Use Case

Use Cases encapsulate single business operations:

```swift
protocol GetUsersUseCaseContract: Sendable {
  func execute() async throws -> [User]
}

struct GetUsersUseCase: GetUsersUseCaseContract {
  private let repository: UserRepositoryContract

  init(repository: UserRepositoryContract) {
    self.repository = repository
  }

  func execute() async throws -> [User] {
    try await repository.getUsers()
  }
}
```

### Repository

Repositories abstract data access:

```swift
protocol UserRepositoryContract: Sendable {
  func getUsers() async throws -> [User]
  func getUser(id: UUID) async throws -> User
}

struct UserRepository: UserRepositoryContract {
  private let remoteDataSource: UserRemoteDataSourceContract

  init(remoteDataSource: UserRemoteDataSourceContract) {
    self.remoteDataSource = remoteDataSource
  }

  func getUsers() async throws -> [User] {
    let dtos = try await remoteDataSource.fetchUsers()
    return dtos.map { $0.toDomain() }
  }

  func getUser(id: UUID) async throws -> User {
    let dto = try await remoteDataSource.fetchUser(id: id)
    return dto.toDomain()
  }
}
```

### Coordinator

Coordinators manage navigation using `NavigationStack`:

```swift
@MainActor
final class UserCoordinator: ObservableObject {
  @Published var path = NavigationPath()

  enum Destination: Hashable {
    case userDetail(User)
    case userSettings(User)
  }

  func showUserDetail(_ user: User) {
    path.append(Destination.userDetail(user))
  }

  func showUserSettings(_ user: User) {
    path.append(Destination.userSettings(user))
  }

  func pop() {
    path.removeLast()
  }

  func popToRoot() {
    path.removeLast(path.count)
  }

  @ViewBuilder
  func build(destination: Destination) -> some View {
    switch destination {
    case .userDetail(let user):
      UserDetailView(viewModel: makeUserDetailViewModel(user: user))
    case .userSettings(let user):
      UserSettingsView(viewModel: makeUserSettingsViewModel(user: user))
    }
  }

  private func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
    // Create and inject dependencies
  }

  private func makeUserSettingsViewModel(user: User) -> UserSettingsViewModel {
    // Create and inject dependencies
  }
}
```

Usage in SwiftUI:

```swift
struct UserFlowView: View {
  @StateObject private var coordinator = UserCoordinator()

  var body: some View {
    NavigationStack(path: $coordinator.path) {
      UserListView(viewModel: makeUserListViewModel())
        .navigationDestination(for: UserCoordinator.Destination.self) { destination in
          coordinator.build(destination: destination)
        }
    }
    .environmentObject(coordinator)
  }
}
```

---

## Project Structure

The project uses **feature-based modularization**. Each feature is a separate framework module.

### Feature Naming

Feature directory names must **not** contain the word "Feature". Use simple, descriptive names:

```
// RIGHT
Libraries/Features/User/
Libraries/Features/Character/
Libraries/Features/Home/

// WRONG
Libraries/Features/UserFeature/
Libraries/Features/CharacterFeature/
```

### Directory Structure

```
Challenge/
├── App/
│   ├── Sources/
│   │   ├── ChallengeApp.swift
│   │   └── Resources/
│   ├── Tests/
│   └── UITests/
├── Libraries/
│   ├── Core/
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── Networking/
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   └── Features/
│       ├── User/
│       │   ├── Sources/
│       │   │   ├── Domain/
│       │   │   │   ├── Models/
│       │   │   │   ├── UseCases/
│       │   │   │   └── Repositories/
│       │   │   ├── Data/
│       │   │   │   ├── DataSources/
│       │   │   │   ├── DTOs/
│       │   │   │   └── Repositories/
│       │   │   └── Presentation/
│       │   │       ├── Views/
│       │   │       ├── ViewModels/
│       │   │       └── Coordinators/
│       │   ├── Tests/
│       │   └── Mocks/
│       └── Home/
│           ├── Sources/
│           ├── Tests/
│           └── Mocks/
├── Tuist/
│   └── ProjectDescriptionHelpers/
├── docs/
│   └── StyleGuide.md
├── Project.swift
├── Tuist.swift
└── CLAUDE.md
```

### Feature Module Structure

Each feature module follows this internal structure:

```
FeatureName/
├── Sources/
│   ├── Domain/
│   │   ├── Models/             # Domain models
│   │   ├── UseCases/           # Business logic
│   │   └── Repositories/       # Repository contracts (protocols)
│   ├── Data/
│   │   ├── DataSources/        # Remote/Local data sources
│   │   ├── DTOs/               # Data Transfer Objects
│   │   └── Repositories/       # Repository implementations
│   └── Presentation/
│       ├── Views/              # SwiftUI views
│       ├── ViewModels/         # ViewModels
│       └── Coordinators/       # Navigation coordinators
├── Tests/
│   ├── Domain/
│   │   └── UseCases/           # Use case tests
│   ├── Data/
│   │   └── Repositories/       # Repository tests
│   └── Presentation/
│       ├── ViewModels/         # ViewModel tests
│       └── Snapshots/          # Snapshot tests
└── Mocks/
    ├── UseCasesMock.swift
    ├── RepositoriesMock.swift
    └── DataSourcesMock.swift
```

### Extensions

Extensions of external framework types (Foundation, UIKit, SwiftUI, etc.) must be placed in an `Extensions/` folder. Create one file per extended type using the naming convention `TypeName+Purpose.swift`.

```
Sources/
├── Extensions/
│   ├── URL+QueryItems.swift
│   ├── Date+Formatting.swift
│   └── String+Validation.swift
└── ...

Tests/
├── Extensions/
│   ├── URLSession+Mock.swift
│   ├── HTTPURLResponse+Mock.swift
│   └── URLRequest+BodyData.swift
└── ...
```

**Naming convention:** `TypeName+Purpose.swift`

```swift
// URL+QueryItems.swift
extension URL {
	func appendingQueryItems(_ items: [URLQueryItem]) -> URL { ... }
}

// URLSession+Mock.swift (in Tests)
extension URLSession {
	static func mockSession() -> URLSession { ... }
}
```

---

## Dependencies

### General Policy

- **Prefer native implementations** over external libraries
- Use external dependencies **only when strictly necessary**
- All external dependencies are managed via **Swift Package Manager (SPM)**

### Allowed Dependencies

| Dependency | Purpose | Notes |
|------------|---------|-------|
| SnapshotTesting | Snapshot tests | Point-Free library for UI snapshot testing |
| SwiftLint | Code linting | Installed via mise, not SPM |

### Adding Dependencies

When absolutely necessary to add a dependency:

1. Evaluate if the functionality can be implemented natively
2. Check the library's maintenance status and Swift 6 compatibility
3. Add via SPM in the appropriate module's `Package.swift` or Tuist configuration

---

## Networking

Native networking layer using **URLSession with async/await**. No external dependencies.

**Location:** `Libraries/Networking/`

**Documentation:** See [Libraries/Networking/README.md](Libraries/Networking/README.md)

### Components

| Component | Description |
|-----------|-------------|
| `HTTPClientContract` | Protocol for HTTP client (enables DI) |
| `HTTPClient` | Sendable final class implementation |
| `Endpoint` | Request configuration |
| `HTTPMethod` | GET, POST, PUT, PATCH, DELETE |
| `HTTPError` | Error types |
| `HTTPClientMock` | Mock for testing |

### Quick Example

```swift
import ChallengeNetworking

// Production code: handle URL creation safely
guard let baseURL = URL(string: "https://api.example.com") else {
	throw ConfigurationError.invalidURL
}

let client = HTTPClient(baseURL: baseURL)

let endpoint = Endpoint(
	path: "/users",
	method: .get,
)

let users: [User] = try await client.request(endpoint)
```

---

## Testing

### Testing Frameworks

| Framework | Usage |
|-----------|-------|
| **Testing** (Swift Testing) | Unit tests, integration tests |
| **SnapshotTesting** | Snapshot tests for UI components |
| **XCTest** | UI tests (end-to-end) |

### Test Coverage Requirements

- All business logic (Use Cases) must have **100% test coverage**
- All ViewModels must have **comprehensive test coverage**
- All public API of shared modules must be tested
- UI components should have **snapshot tests**

### Unit Tests with Swift Testing

```swift
import Testing

@testable import UserFeature

struct GetUsersUseCaseTests {
  @Test
  func returnsUsersFromRepository() async throws {
    let expectedUsers = [User.stub(), User.stub()]
    let repository = UserRepositoryMock(users: expectedUsers)
    let sut = GetUsersUseCase(repository: repository)

    let result = try await sut.execute()

    #expect(result == expectedUsers)
  }

  @Test
  func throwsErrorWhenRepositoryFails() async {
    let repository = UserRepositoryMock(error: TestError.networkError)
    let sut = GetUsersUseCase(repository: repository)

    await #expect(throws: TestError.networkError) {
      try await sut.execute()
    }
  }
}
```

### ViewModel Tests

```swift
import Testing

@testable import UserFeature

@MainActor
struct UserListViewModelTests {
  @Test
  func loadUsersUpdatesState() async {
    let users = [User.stub()]
    let useCase = GetUsersUseCaseMock(result: .success(users))
    let sut = UserListViewModel(getUsersUseCase: useCase, coordinator: nil)

    await sut.loadUsers()

    #expect(sut.users == users)
    #expect(sut.isLoading == false)
    #expect(sut.error == nil)
  }

  @Test
  func loadUsersHandlesError() async {
    let useCase = GetUsersUseCaseMock(result: .failure(TestError.networkError))
    let sut = UserListViewModel(getUsersUseCase: useCase, coordinator: nil)

    await sut.loadUsers()

    #expect(sut.users.isEmpty)
    #expect(sut.isLoading == false)
    #expect(sut.error != nil)
  }
}
```

### Snapshot Tests

```swift
import SnapshotTesting
import Testing

@testable import UserFeature

struct UserRowViewSnapshotTests {
  @Test
  func defaultState() {
    let view = UserRowView(user: .stub())

    assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
  }

  @Test
  func longUserName() {
    let user = User.stub(name: "Very Long User Name That Should Truncate Properly")
    let view = UserRowView(user: user)

    assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
  }
}
```

### UI Tests (End-to-End) with XCTest

```swift
import XCTest

final class UserFlowUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()
  }

  func testUserListDisplaysUsers() throws {
    let userList = app.collectionViews["userList"]
    XCTAssertTrue(userList.waitForExistence(timeout: 5))

    let firstUser = userList.cells.firstMatch
    XCTAssertTrue(firstUser.exists)
  }

  func testNavigationToUserDetail() throws {
    let userList = app.collectionViews["userList"]
    _ = userList.waitForExistence(timeout: 5)

    userList.cells.firstMatch.tap()

    let detailView = app.otherElements["userDetailView"]
    XCTAssertTrue(detailView.waitForExistence(timeout: 2))
  }
}
```

### Mocks

Mock names must end with `Mock` suffix. Place mocks based on their visibility:

| Location | Visibility | Usage |
|----------|------------|-------|
| `Mocks/` (framework) | Public | Mocks used by other modules (e.g., `ChallengeNetworkingMocks`) |
| `Tests/Mocks/` | Internal | Mocks only used within the test target |

```
FeatureName/
├── Mocks/                    # Public mocks (ChallengeFeatureNameMocks framework)
│   └── UserRepositoryMock.swift
└── Tests/
    ├── Mocks/                # Internal test-only mocks
    │   └── TestHelperMock.swift
    └── UseCaseTests.swift
```

**Public mock** (in `Mocks/` framework, usable by other modules):

```swift
// Mocks/UserRepositoryMock.swift
import Foundation
import ChallengeUserFeature

public final class UserRepositoryMock: UserRepositoryContract, @unchecked Sendable {
	public var users: [User]
	public var error: Error?

	public init(users: [User] = [], error: Error? = nil) {
		self.users = users
		self.error = error
	}

	public func getUsers() async throws -> [User] {
		if let error { throw error }
		return users
	}

	public func getUser(id: UUID) async throws -> User {
		if let error { throw error }
		guard let user = users.first(where: { $0.id == id }) else {
			throw NotFoundError.notFound
		}
		return user
	}
}
```

**Internal mock** (in `Tests/Mocks/`, only for this test target):

```swift
// Tests/Mocks/URLProtocolMock.swift
import Foundation

final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

	nonisolated override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	nonisolated override class func canInit(with request: URLRequest) -> Bool { true }
	nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	nonisolated override func startLoading() {
		guard let handler = URLProtocolMock.requestHandler else {
			assertionFailure("Request handler not set")
			return
		}
		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			if let data {
				client?.urlProtocol(self, didLoad: data)
			}
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	nonisolated override func stopLoading() {}
}
```

### Stubs (Test Data)

Use the **stub pattern** to create test data. Stubs are extensions on domain models that provide factory methods with sensible defaults.

**Location:** `Tests/Stubs/`

```
FeatureName/
└── Tests/
    ├── Stubs/                    # Test data factories
    │   ├── Character+Stub.swift
    │   └── Location+Stub.swift
    ├── Mocks/
    └── Data/
```

**Stub extension pattern:**

```swift
// Tests/Stubs/User+Stub.swift
extension User {
    static func stub(
        id: Int = 1,
        name: String = "John Doe",
        email: String = "john@example.com",
    ) -> User {
        User(
            id: id,
            name: name,
            email: email
        )
    }
}
```

**Rules:**
- File naming: `{TypeName}+Stub.swift`
- Method name: `static func stub(...)`
- All parameters must have default values
- Defaults should be valid, realistic values
- Located in `Tests/Stubs/` (internal to test target)

**Usage in tests:**

```swift
@Test
func processesUserCorrectly() {
    // Default stub
    let user = User.stub()

    // Customized stub
    let admin = User.stub(name: "Admin", role: .admin)

    // Multiple stubs
    let users = [User.stub(id: 1), User.stub(id: 2)]
}
```

**DTOs also use stubs** when needed for repository/datasource tests:

```swift
// Tests/Stubs/UserDTO+Stub.swift
extension UserDTO {
    static func stub(
        id: Int = 1,
        name: String = "John Doe",
    ) -> UserDTO {
        UserDTO(id: id, name: name)
    }
}
```

---

## Style Guide

All generated code **must** follow these rules. For the complete guide, see `docs/StyleGuide.md`.

### Formatting

| Rule | Value |
|------|-------|
| Indentation | 1 tab |
| Maximum line width | 140 characters |
| Trailing commas | Required in multi-line collections |
| Blank lines | Single blank line between declarations |
| End of file | Single newline at end |

### Spacing

```swift
// Colons: space after, not before
let name: String
func method(param: Int) -> String
let dict: [String: Int]

// Operators: space on both sides
let sum = a + b
let range = 0..<10

// Braces: space before opening, space inside for single-line
func method() { }
array.map { $0 * 2 }

// Parentheses: no space inside
func method(param: Int)
if condition {
```

### Imports

```swift
// Alphabetized, @testable after blank line
import Foundation
import SwiftUI
import UIKit

@testable import UserFeature
```

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Types, Protocols | PascalCase | `UserRepository`, `SpaceThing` |
| Variables, Functions | lowerCamelCase | `userName`, `fetchData()` |
| Booleans | is/has/can prefix | `isEnabled`, `hasLoaded`, `canSubmit` |
| **Protocols** | **`Contract` suffix** | `UserRepositoryContract` |
| **Mocks** | **`Mock` suffix only** | `UserRepositoryMock` |

**Mock naming rule:** `Mock` must **only** be used as a suffix, **never as a prefix**:

```swift
// RIGHT - Mock as suffix
class UserRepositoryMock { }
class HTTPClientMock { }
let userMock = UserMock()
var dataMock: DataMock

// WRONG - Mock as prefix (PROHIBITED)
class MockUserRepository { }
enum MockError { }
struct MockData { }
let mockUser = UserMock()
var mockData: DataMock
```

### Code Style

```swift
// WRONG - Redundant type
let name: String = "John"
let count: Int = 0

// RIGHT - Inferred type
let name = "John"
let count = 0
```

```swift
// WRONG - Unnecessary self
self.name = "John"
self.save()

// RIGHT - Omit self unless required
name = "John"
save()
```

```swift
// WRONG - Explicit return in single expression
var body: some View {
  return Text("Hello")
}

// RIGHT - Implicit return
var body: some View {
  Text("Hello")
}
```

```swift
// WRONG - Redundant closure
let action = { performAction() }()

// RIGHT - Direct call
let action = performAction()
```

### Force Unwrap

**Never use force unwrap (`!`).** Always handle optionals safely:

```swift
// WRONG - Force unwrap
let url = URL(string: urlString)!
let user = users.first!
let value = dictionary["key"]!

// RIGHT - guard let
guard let url = URL(string: urlString) else {
	throw ConfigurationError.invalidURL
}

// RIGHT - if let
if let user = users.first {
	process(user)
}

// RIGHT - nil coalescing
let value = dictionary["key"] ?? defaultValue

// RIGHT - Optional chaining
let name = user?.profile?.name
```

**In tests**, use `#require` for safe unwrapping:

```swift
// RIGHT - #require in tests (fails test if nil)
let baseURL = try #require(URL(string: "https://api.example.com"))
let data = try #require(response.data)
let user = try #require(users.first)

// RIGHT - Optional comparison (no unwrap needed)
#expect(request.url?.absoluteString == "https://api.example.com/users")

// RIGHT - Nil coalescing for non-throwing contexts (e.g., closures)
return (HTTPURLResponse.ok(url: request.url ?? baseURL), Data())
```

### Avoiding Warnings

```swift
// WRONG - Unused variable
let client = HTTPClient(baseURL: url)
// client never used → warning

// RIGHT - Use the variable or don't declare it
let client = HTTPClient(baseURL: url)
let result = try await client.request(endpoint)

// RIGHT - If intentionally unused, use underscore
let _ = HTTPClient(baseURL: url)
```

```swift
// WRONG - Unused parameter
func process(data: Data, options: Options) {
	print(data)
	// options never used → warning
}

// RIGHT - Use underscore for intentionally unused
func process(data: Data, options _: Options) {
	print(data)
}
```

```swift
// WRONG - Unused import
import UIKit  // Not used in this file

// RIGHT - Only import what you use
import Foundation
```

```swift
// WRONG - Result of call unused
array.map { $0 * 2 }  // warning: result unused

// RIGHT - Assign or use @discardableResult
let doubled = array.map { $0 * 2 }

// RIGHT - Explicitly discard if intentional
_ = array.map { $0 * 2 }
```

### Trailing Commas

```swift
// RIGHT - Trailing comma in multi-line
let planets = [
  "Mercury",
  "Venus",
  "Earth",
]

func configure(
  name: String,
  age: Int,
) { }

// RIGHT - No trailing comma in single-line
let planets = ["Mercury", "Venus", "Earth"]
```

### Protocol Conformance

```swift
// RIGHT - Separate extensions for protocol conformance
class MyViewController: UIViewController {
  // Core implementation
}

// MARK: - UITableViewDelegate

extension MyViewController: UITableViewDelegate {
  // Delegate methods
}
```

### Dependency Injection

```swift
// RIGHT - Protocol injection
final class UserListViewModel {
  private let useCase: GetUsersUseCaseContract

  init(useCase: GetUsersUseCaseContract) {
    self.useCase = useCase
  }
}

// WRONG - Concrete type
final class UserListViewModel {
  private let useCase: GetUsersUseCase
}
```

### Code Organization

Organize type contents in this order:

1. **Properties first** - All properties (private, internal, public) at the beginning
2. **Initializers** - init, deinit
3. **Public/Internal methods** - API methods
4. **Private methods** - In a `private extension` of the same type

```swift
// RIGHT - Properties first, private methods in extension
public actor HTTPClient {
	private let session: URLSession
	private let baseURL: URL
	private let decoder: JSONDecoder

	public init(baseURL: URL, session: URLSession = .shared) {
		self.baseURL = baseURL
		self.session = session
		self.decoder = JSONDecoder()
	}

	public func request(_ endpoint: Endpoint) async throws -> Data {
		let request = try buildRequest(for: endpoint)
		// ...
	}
}

private extension HTTPClient {
	func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
		// ...
	}
}
```

```swift
// WRONG - Mixed organization with MARK comments
public actor HTTPClient {
	// MARK: Lifecycle
	public init(...) { }

	// MARK: Public
	public func request(...) { }

	// MARK: Private
	private let session: URLSession
	private func buildRequest(...) { }
}
```

Use `// MARK:` only for protocol conformance extensions:

```swift
// MARK: - CustomStringConvertible

extension HTTPError: CustomStringConvertible {
	var description: String { ... }
}
```

### SwiftUI

```swift
// RIGHT - Implicit ViewBuilder, no redundant return
var body: some View {
  VStack {
    Text("Title")
    Button("Action") { }
  }
}

// WRONG - Explicit ViewBuilder and return
@ViewBuilder
var body: some View {
  return VStack {
    Text("Title")
    Button("Action") { }
  }
}
```

### Testing (Swift Testing)

#### Naming: System Under Test (SUT)

Always name the object being tested as `sut` (System Under Test):

```swift
// RIGHT - Object under test named sut
let sut = GetUserUseCase(client: mockClient)
let result = try await sut.execute()

// WRONG - Generic or unclear names
let useCase = GetUserUseCase(client: mockClient)
let getUserUseCase = GetUserUseCase(client: mockClient)
```

#### Structure: Given / When / Then

All tests must use `// Given`, `// When`, `// Then` comments:

```swift
@Test
func fetchesUserSuccessfully() async throws {
	// Given
	let expectedUser = User(id: 1, name: "John")
	let mockClient = HTTPClientMock(result: .success(expectedUser.encoded()))
	let sut = GetUserUseCase(client: mockClient)

	// When
	let result = try await sut.execute(userId: 1)

	// Then
	#expect(result == expectedUser)
}
```

#### Parameterized Tests: Use `@Test(arguments:)`

Always prefer `@Test(arguments:)` for testing multiple cases:

```swift
// RIGHT - Parameterized test
@Test(arguments: [
	HTTPMethod.get,
	HTTPMethod.post,
	HTTPMethod.put,
	HTTPMethod.patch,
	HTTPMethod.delete,
])
func endpointSupportsHTTPMethod(_ method: HTTPMethod) {
	// Given
	let path = "/test"

	// When
	let sut = Endpoint(path: path, method: method)

	// Then
	#expect(sut.method == method)
}

// WRONG - Loop inside test
@Test
func endpointSupportsAllMethods() {
	for method in [HTTPMethod.get, .post, .put] {
		let endpoint = Endpoint(path: "/test", method: method)
		#expect(endpoint.method == method)
	}
}
```

#### Multiple Arguments

```swift
@Test(arguments: [
	(404, 404, true),
	(404, 500, false),
	(200, 200, true),
])
func httpErrorStatusCodeEquality(
	lhsCode: Int,
	rhsCode: Int,
	expectedEqual: Bool,
) {
	// Given
	let data = Data("test".utf8)
	let lhs = HTTPError.statusCode(lhsCode, data)
	let rhs = HTTPError.statusCode(rhsCode, data)

	// When
	let areEqual = lhs == rhs

	// Then
	#expect(areEqual == expectedEqual)
}
```

#### Assertions

```swift
// Use #expect for assertions
#expect(value == expected)
#expect(array.isEmpty)
#expect(count > 0)

// Use #require for unwrapping (fails test if nil)
let data = try #require(response.data)
let user = try #require(users.first)

// Use #expect(throws:) for error testing
await #expect(throws: HTTPError.invalidURL) {
	try await client.request(invalidEndpoint)
}
```

#### Comparing Results

**Always compare full objects** instead of checking individual properties. This ensures all fields are verified and makes tests more maintainable.

```swift
// RIGHT - Compare full objects using stubs
@Test
func fetchesCharacterCorrectly() async throws {
	// Given
	let expected = Character.stub()
	let dataSource = CharacterDataSourceMock(result: .success(.stub()))
	let sut = CharacterRepository(dataSource: dataSource)

	// When
	let value = try await sut.getCharacter(id: 1)

	// Then
	#expect(value == expected)
}

// WRONG - Checking individual properties
@Test
func fetchesCharacterCorrectly() async throws {
	// ...
	let result = try await sut.getCharacter(id: 1)

	#expect(result.id == 1)
	#expect(result.name == "Rick Sanchez")
	#expect(result.status == .alive)
	#expect(result.species == "Human")
}
```

**Rules:**
- Use `value` as the variable name for the result being tested (not `result`)
- Create an `expected` variable with the stub matching the expected output
- Compare with a single `#expect(value == expected)`
- Use customized stubs when testing specific transformations

#### Naming

```swift
// RIGHT - Descriptive, no "test" prefix
func returnsCorrectValue() { }
func throwsErrorWhenInvalid() { }
func fetchesUserSuccessfully() { }

// WRONG - "test" prefix
func testReturnsCorrectValue() { }
func testThrowsError() { }
```

### SwiftLint

SwiftLint is installed via **mise** (not SPM). Configuration is in `.swiftlint.yml`.

```bash
mise install swiftlint
swiftlint          # Run linter
swiftlint --fix    # Auto-fix issues
```

#### Enforced Limits

| Rule | Warning | Error |
|------|---------|-------|
| Line length | 140 | 200 |
| File length | 500 | 1000 |
| Type body length | 300 | 500 |
| Function body length | 50 | 100 |
| Cyclomatic complexity | 10 | 20 |

#### Custom Rules

The following project-specific rules are enforced:

| Rule | Severity | Description |
|------|----------|-------------|
| `protocol_contract_suffix` | warning | Protocols must end with `Contract` |
| `mock_suffix` | warning | Mocks must end with `Mock` |
| `no_mock_prefix` | error | `Mock` cannot be used as prefix (only suffix) |
| `no_dispatch_queue` | error | Use async/await, not DispatchQueue |
| `no_completion_handler` | warning | Use async/await, not completion handlers |

---

## Tuist Configuration

The project uses Tuist for project generation and module management.

### Key Files

| File | Purpose |
|------|---------|
| `Project.swift` | Main project definition |
| `Tuist.swift` | Tuist configuration |
| `Tuist/ProjectDescriptionHelpers/Config.swift` | Shared configuration |
| `Tuist/ProjectDescriptionHelpers/FrameworkModule.swift` | Framework module helper (targets + schemes) |
| `Tuist/ProjectDescriptionHelpers/Dependencies.swift` | XCFramework dependencies |

### Module Naming Rules

- Module `name` must **not** contain "/" or special characters
- Module `name` becomes the target name (e.g., `name: "Character"` → `ChallengeCharacter`)
- Use `path` parameter when the directory differs from the name (e.g., `path: "Features/Character"`)

```
// RIGHT
name: "Character", path: "Features/Character"  → Target: ChallengeCharacter
name: "Networking"                              → Target: ChallengeNetworking

// WRONG
name: "Features/Character"  → "/" not allowed in name
```

### Creating a Framework

Use `FrameworkModule.create()` to generate targets and schemes together:

```swift
// In Project.swift

// Simple module (sources in Libraries/Networking/)
let networkingModule = FrameworkModule.create(name: "Networking")

// Feature module (sources in Libraries/Features/Home/)
// Use `path` when the directory differs from the module name
let homeModule = FrameworkModule.create(
	name: "Home",
	path: "Features/Home",
	dependencies: [.target(name: "\(appName)Networking")],
)

// Module with internal mocks only (no public Mocks framework)
let characterModule = FrameworkModule.create(
	name: "Character",
	path: "Features/Character",
	dependencies: [.target(name: "\(appName)Networking")],
	hasMocks: false,
)

let project = Project(
	name: appName,
	targets: [
		// App targets...
	] + networkingModule.targets + homeModule.targets,
	schemes: [
		// App scheme...
	] + networkingModule.schemes + homeModule.schemes
)
```

**Each module creates:**

| Type | Name | Description |
|------|------|-------------|
| Framework | `ChallengeNetworking` | Main framework (Sources/) |
| Framework | `ChallengeNetworkingMocks` | Mocks for testing (Mocks/) |
| Unit Tests | `ChallengeNetworkingTests` | Test target (Tests/) |
| Scheme | `ChallengeNetworking` | With **code coverage enabled** |

### External Dependencies

External xcframeworks are stored in `Tuist/Dependencies/`. This directory is **ignored by git** and should not be committed to the repository.

For detailed instructions on adding xcframeworks, use the `/tuist` skill.

### Commands

```bash
# Generate Xcode project
tuist generate

# Clean derived data
tuist clean

# Run tests
tuist test
```

---

## Skills Reference

This project supports Claude Code Skills for automating common tasks. Skills are configured in `.claude/skills/` directory.

**Important:** All skills must be written in **English**.

For more information about Claude Code Skills, see:
https://docs.anthropic.com/en/docs/claude-code/skills

### Available Skills

| Skill | Description |
|-------|-------------|
| `/tuist` | Tuist configuration: adding xcframeworks, managing dependencies |
| `/datasource` | Create RemoteDataSources that consume REST APIs |
| `/repository` | Create Repositories that abstract data sources (Contract in Domain, Implementation in Data) |

---

## Quick Reference

### Prohibited Patterns

```swift
// Never use
DispatchQueue.main.async { }
DispatchQueue.global().async { }
completion: @escaping (Result<T, Error>) -> Void
NotificationCenter for async events
Combine for new code (use async/await)
```

### Required Patterns

```swift
// Always use
async/await for asynchronous code
@MainActor for UI-related code
actors for shared mutable state
Sendable conformance for types crossing isolation boundaries
protocols (contracts) for dependency injection
Contract suffix for protocols (e.g., UserRepositoryContract)
Mock suffix for mocks (e.g., UserRepositoryMock)
Alphabetically ordered imports
```

### Commands

```bash
# Generate Xcode project
tuist generate

# Clean derived data
tuist clean

# Run tests
tuist test

# Lint code
swiftlint
```
