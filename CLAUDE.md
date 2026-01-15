# Project Guidelines

This document defines the coding standards, architecture patterns, and development practices for this iOS project. All code and documentation must be written in **English**.

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

- **Swift 6** with strict concurrency checking enabled
- **iOS 16.0+** minimum deployment target
- **SwiftUI** as the primary UI framework

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
│       ├── UserFeature/
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
│       └── HomeFeature/
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

All networking uses native **URLSession with async/await**. No external libraries.

### HTTP Client Contract

```swift
protocol HTTPClientContract: Sendable {
  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
  func request(_ endpoint: Endpoint) async throws -> Data
}
```

### Endpoint Definition

```swift
struct Endpoint: Sendable {
  let path: String
  let method: HTTPMethod
  let headers: [String: String]
  let queryItems: [URLQueryItem]?
  let body: Data?

  init(
    path: String,
    method: HTTPMethod = .get,
    headers: [String: String] = [:],
    queryItems: [URLQueryItem]? = nil,
    body: Data? = nil
  ) {
    self.path = path
    self.method = method
    self.headers = headers
    self.queryItems = queryItems
    self.body = body
  }
}

enum HTTPMethod: String, Sendable {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}
```

### HTTP Client Implementation

```swift
actor HTTPClient: HTTPClientContract {
  private let session: URLSession
  private let baseURL: URL
  private let decoder: JSONDecoder

  init(
    baseURL: URL,
    session: URLSession = .shared,
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.baseURL = baseURL
    self.session = session
    self.decoder = decoder
  }

  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    let data = try await request(endpoint)
    return try decoder.decode(T.self, from: data)
  }

  func request(_ endpoint: Endpoint) async throws -> Data {
    let request = try buildRequest(for: endpoint)
    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HTTPError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw HTTPError.statusCode(httpResponse.statusCode, data)
    }

    return data
  }

  private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
    var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
    components?.queryItems = endpoint.queryItems

    guard let url = components?.url else {
      throw HTTPError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.httpBody = endpoint.body

    for (key, value) in endpoint.headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    return request
  }
}
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

Create mocks in the `Mocks/` directory of each feature. Mock names must end with `Mock` suffix:

```swift
// Mocks/UserRepositoryMock.swift
import Foundation

@testable import UserFeature

final class UserRepositoryMock: UserRepositoryContract, @unchecked Sendable {
  private let users: [User]
  private let error: Error?

  init(users: [User] = [], error: Error? = nil) {
    self.users = users
    self.error = error
  }

  func getUsers() async throws -> [User] {
    if let error { throw error }
    return users
  }

  func getUser(id: UUID) async throws -> User {
    if let error { throw error }
    guard let user = users.first(where: { $0.id == id }) else {
      throw TestError.notFound
    }
    return user
  }
}
```

---

## Style Guide

All generated code **must** follow these rules. For the complete guide, see `docs/StyleGuide.md`.

### Formatting

| Rule | Value |
|------|-------|
| Indentation | 2 tabs |
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
| **Mocks** | **`Mock` suffix** | `UserRepositoryMock` |

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

### MARK Comments

Use `// MARK:` to organize type contents in this order:

1. `// MARK: Lifecycle` - init, deinit
2. `// MARK: Open` - open properties and methods
3. `// MARK: Public` - public properties and methods
4. `// MARK: Package` - package properties and methods
5. `// MARK: Internal` - internal properties and methods
6. `// MARK: Fileprivate` - fileprivate properties and methods
7. `// MARK: Private` - private properties and methods

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

```swift
// RIGHT - No test prefix, use #expect
@Test
func returnsCorrectValue() async throws {
  let result = try await sut.execute()
  #expect(result == expected)
}

// WRONG - test prefix, XCTAssert
@Test
func testReturnsCorrectValue() async throws {
  let result = try await sut.execute()
  XCTAssertEqual(result, expected)
}
```

```swift
// RIGHT - Use #require instead of guard
@Test
func processesData() throws {
  let data = try #require(response.data)
  #expect(data.count > 0)
}

// WRONG - Guard in tests
@Test
func processesData() throws {
  guard let data = response.data else {
    XCTFail("No data")
    return
  }
}
```

### SwiftLint

SwiftLint is installed via **mise** (not SPM). Configuration is in `.swiftlint.yml`.

```bash
mise install swiftlint
```

---

## Tuist Configuration

The project uses Tuist for project generation and module management.

### Key Files

| File | Purpose |
|------|---------|
| `Project.swift` | Main project definition |
| `Tuist.swift` | Tuist configuration |
| `Tuist/ProjectDescriptionHelpers/Config.swift` | Shared configuration |
| `Tuist/ProjectDescriptionHelpers/Target+Framework.swift` | Framework helpers |
| `Tuist/ProjectDescriptionHelpers/Dependencies.swift` | XCFramework dependencies |

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

For more information about Claude Code Skills, see:
https://docs.anthropic.com/en/docs/claude-code/skills

### Available Skills

| Skill | Description |
|-------|-------------|
| `/tuist` | Tuist configuration: adding xcframeworks, managing dependencies |

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
