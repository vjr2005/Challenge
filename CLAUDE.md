# Project Guidelines

This document defines the coding standards, architecture patterns, and development practices for this iOS project. All code and documentation must be written in **English**.

> **CRITICAL:** All generated code must compile without errors or warnings. Before writing code, carefully analyze for:
> - Unused variables, parameters, or imports
> - Missing protocol conformances
> - Type mismatches
> - Concurrency issues (Sendable, actor isolation)
> - Implicit returns where explicit are needed
> - **Never use force unwrap (`!`)** - use `guard let`, `if let`, or `try?` instead
>
> **After writing code, always verify compilation** by running `tuist test`. Never assume code compiles correctly.
>
> **All code must pass SwiftLint validation.** This includes generated code and documentation examples (README files, skills, etc.). All code snippets must be valid, compilable Swift that adheres to this style guide and SwiftLint rules.
>
> **Maximum test coverage is required.** When creating or modifying any component (UseCase, Repository, DataSource, ViewModel, etc.), all related changes must be fully tested. For example, when creating a UseCase that requires modifying a Repository and DataSource, tests must be created/updated for all three layers.

## Table of Contents

- [Swift Version and Concurrency](#swift-version-and-concurrency)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Networking](#networking)
- [App Configuration](#app-configuration)
- [Testing](#testing)
- [Style Guide](#style-guide)
- [Tuist Configuration](#tuist-configuration)
- [Skills Reference](#skills-reference)

---

## Swift Version and Concurrency

### Requirements

- **Swift 6** with:
  - `SWIFT_APPROACHABLE_CONCURRENCY = YES` (improved inference)
  - `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (default isolation)
- **iOS 17.0+** minimum deployment target
- **SwiftUI** as the primary UI framework
- **@Observable** for state management (not ObservableObject)

### Default MainActor Isolation

With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, **all types are MainActor-isolated by default**. This means:

- No need for explicit `@MainActor` on ViewModels, Views, or UI-related types
- Types that need to run off the main thread must opt out using `nonisolated`

### Approachable Concurrency

With `SWIFT_APPROACHABLE_CONCURRENCY = YES`, the compiler **automatically infers `Sendable`** conformance:

- Structs with all Sendable properties are implicitly Sendable
- No need to explicitly mark types as `Sendable`
- Enums with Sendable associated values are implicitly Sendable

```swift
// This struct is automatically Sendable (all properties are Sendable)
struct User: Equatable {
  let id: Int
  let name: String
}

// No need to write:
// struct User: Equatable, Sendable { ... }
```

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

// REQUIRED - Use actors for shared mutable state (opt out of MainActor)
actor DataStore {
  private var cache: [String: Data] = [:]

  func store(_ data: Data, forKey key: String) {
    cache[key] = data
  }
}
```

### Opting Out of MainActor Isolation

Types that need to run off the main thread must explicitly opt out:

#### Actors (custom isolation)

```swift
// Actors have their own isolation domain (not MainActor)
actor CharacterMemoryDataSource {
  private var storage: [Int: CharacterDTO] = [:]

  func save(_ character: CharacterDTO) {
    storage[character.id] = character
  }
}
```

#### Types stored inside actors

Types stored or processed by actors must be `nonisolated`:

```swift
// Types used inside actors need nonisolated
nonisolated struct MyData: Equatable {
  let id: Int
  let value: String
}
```

> **Note:** For DTOs specifically, see the `/datasource` skill.

#### Framework subclasses called from background threads

```swift
// URLProtocol subclasses are called from background threads
final class URLProtocolMock: URLProtocol, @unchecked Sendable {
  nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

  nonisolated override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
    super.init(request: request, cachedResponse: cachedResponse, client: client)
  }

  nonisolated override class func canInit(with request: URLRequest) -> Bool { true }
  nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  nonisolated override func startLoading() { /* ... */ }
  nonisolated override func stopLoading() {}
}
```

---

## Architecture

This project follows **MVVM + Clean Architecture** pattern without external dependencies.

### Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    View     │  │  ViewModel  │  │    Navigation       │  │
│  │  (SwiftUI)  │◄─┤ @Observable │  │  (Cross-module)     │  │
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

Views are pure UI components with no business logic. See `/view` skill for detailed patterns.

### ViewModel

ViewModels manage state and coordinate between View and Use Cases. See `/viewmodel` skill for detailed patterns and examples.

### Use Case

Use Cases encapsulate single business operations. See `/usecase` skill for detailed patterns and examples.

### Repository

Repositories abstract data access and transform DTOs to Domain models. See `/repository` skill for detailed patterns (remote only, local only, local-first).

### Router

Cross-module navigation using `Router` from Core. Router is `@Observable` and owns the `NavigationPath`. Features receive `RouterContract` and pass it to ViewModels. See `/router` skill for detailed patterns.

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
│   │       └── Assets.xcassets/
│   │           ├── AppIcon.appiconset/        # Production icon
│   │           ├── AppIconDev.appiconset/     # Development icon (orange banner)
│   │           └── AppIconStaging.appiconset/ # Staging icon (purple banner)
│   ├── Tests/
│   └── E2ETests/
├── Libraries/
│   ├── Core/
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── Networking/
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── AppConfiguration/
│   │   ├── Sources/
│   │   │   └── Environment.swift
│   │   └── Tests/
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
│       │   │       └── ViewModels/
│       │   ├── Tests/
│       │   └── Mocks/
│       └── Home/
│           ├── Sources/
│           ├── Tests/
│           └── Mocks/
├── Tuist/
│   └── ProjectDescriptionHelpers/
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
│       └── {FeatureName}/      # Group by feature (e.g., CharacterDetail)
│           ├── Views/          # SwiftUI views for this feature
│           └── ViewModels/     # ViewModels for this feature
├── Tests/
│   ├── Domain/
│   │   └── UseCases/           # Use case tests
│   ├── Data/
│   │   └── Repositories/       # Repository tests
│   └── Presentation/
│       └── {FeatureName}/      # Same structure as Sources
│           ├── ViewModels/     # ViewModel tests
│           └── Snapshots/      # Snapshot tests
└── Mocks/
    ├── UseCasesMock.swift
    ├── RepositoriesMock.swift
    └── DataSourcesMock.swift
```

### Presentation Layer Organization

The Presentation layer groups related Views and ViewModels by feature name:

```
Presentation/
├── CharacterDetail/            # Feature: Character detail screen
│   ├── Views/
│   │   └── CharacterDetailView.swift
│   └── ViewModels/
│       ├── CharacterDetailViewModel.swift
│       └── CharacterDetailViewState.swift
├── CharacterList/              # Feature: Character list screen
│   ├── Views/
│   │   └── CharacterListView.swift
│   └── ViewModels/
│       ├── CharacterListViewModel.swift
│       └── CharacterListViewState.swift
└── ...
```

**Naming conventions:**
- Folder name matches the feature (e.g., `CharacterDetail`)
- View: `{FeatureName}View.swift` (e.g., `CharacterDetailView.swift`)
- ViewModel: `{FeatureName}ViewModel.swift` (e.g., `CharacterDetailViewModel.swift`)
- ViewState: `{FeatureName}ViewState.swift` (e.g., `CharacterDetailViewState.swift`)

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

| Component | Visibility | Description |
|-----------|------------|-------------|
| `HTTPClientContract` | **public** | Protocol for HTTP client (enables DI) |
| `HTTPClient` | **public (open)** | Implementation using URLSession |
| `Endpoint` | **public** | Request configuration |
| `HTTPMethod` | **public** | GET, POST, PUT, PATCH, DELETE |
| `HTTPError` | **public** | Error types |
| `HTTPClientMock` | **public** | Mock for testing (in Mocks target) |

### Quick Example

```swift
import ChallengeNetworking

guard let baseURL = URL(string: "https://api.example.com") else {
    fatalError("Invalid API base URL")
}

let client = HTTPClient(baseURL: baseURL)

let endpoint = Endpoint(
    path: "/users",
    method: .get
)

let users: [User] = try await client.request(endpoint)
```

---

## App Configuration

Environment and API configuration module.

**Location:** `Libraries/AppConfiguration/`

### Environment

The `Environment` enum defines the application environments and provides API configuration.

```swift
import ChallengeAppConfiguration

// Get current environment (determined at compile time)
let environment = Environment.current

// Check environment type
if environment.isDebug {
    // Development-only code
}

// Get API configuration
let apiURL = Environment.current.rickAndMorty.baseURL
```

### Environment Cases

| Case | Description |
|------|-------------|
| `development` | Local development with debug tools |
| `staging` | Pre-production testing environment |
| `production` | Live production environment |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `current` | `Environment` | Current environment based on build configuration |
| `isDebug` | `Bool` | `true` only for `development` |
| `isRelease` | `Bool` | `true` only for `production` |
| `rickAndMorty` | `API` | API configuration with `baseURL` |

### Build Configurations

The project uses multiple build configurations to support different environments:

| Configuration | Type | Bundle ID | App Icon | Environment |
|---------------|------|-----------|----------|-------------|
| Debug | debug | `.dev` | AppIconDev | development |
| Debug-Staging | debug | `.staging` | AppIconStaging | staging |
| Debug-Prod | debug | (none) | AppIcon | production |
| Staging | release | `.staging` | AppIconStaging | staging |
| Release | release | (none) | AppIcon | production |

**Debug configurations** enable debugging and development tools.
**Release configurations** are optimized builds for distribution.

### Schemes

| Scheme | Run Config | Archive Config | Use Case |
|--------|------------|----------------|----------|
| `Challenge (Dev)` | Debug | Release | Daily development |
| `Challenge (Staging)` | Debug-Staging | Staging | Testing with staging API |
| `Challenge (Prod)` | Debug-Prod | Release | Debugging production issues |

**Run Config**: Configuration used when running in simulator/device (debuggable).
**Archive Config**: Configuration used when creating archives for distribution.

### App Icons

Each environment has a distinct app icon with a colored banner:

| Environment | Icon | Banner |
|-------------|------|--------|
| Development | AppIconDev | 🟠 Orange "DEV" |
| Staging | AppIconStaging | 🟣 Purple "STAGING" |
| Production | AppIcon | No banner |

Icons are located in `App/Sources/Resources/Assets.xcassets/`.

### Adding a New API

To add a new API endpoint configuration:

```swift
// In Environment.swift
public extension Environment {
    var newAPI: API {
        let urlString: String
        switch self {
        case .development:
            urlString = "https://dev.api.example.com"
        case .staging:
            urlString = "https://staging.api.example.com"
        case .production:
            urlString = "https://api.example.com"
        }
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL: \(urlString)")
        }
        return API(baseURL: url)
    }
}
```

### Usage in Features

Features access API configuration through their Container:

```swift
import ChallengeAppConfiguration
import ChallengeNetworking

final class MyFeatureContainer {
    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: Environment.current.rickAndMorty.baseURL
        )
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

For unit tests, see the respective skills:
- `/datasource` - DataSource tests
- `/repository` - Repository tests
- `/usecase` - UseCase tests
- `/viewmodel` - ViewModel tests
- `/router` - Navigation tests

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

E2E tests use the **Robot Pattern** for better readability and maintainability. Each screen has a Robot that encapsulates UI interactions.

**Important:** With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, UI test classes must be marked as `nonisolated` to avoid conflicts with XCTest's API which is not MainActor-isolated.

#### File Structure

```
App/E2ETests/
├── Robots/
│   ├── Robot.swift              # Base protocol and DSL
│   ├── HomeRobot.swift
│   ├── CharacterListRobot.swift
│   └── CharacterDetailRobot.swift
└── Tests/
    └── CharacterFlowE2ETests.swift
```

#### Robot Protocol

```swift
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
    var app: XCUIApplication { get }
}

/// Provides DSL for robot-based testing.
extension XCTestCase {
    func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    func home(app: XCUIApplication, actions: (HomeRobot) -> Void) {
        actions(HomeRobot(app: app))
    }

    func characterList(app: XCUIApplication, actions: (CharacterListRobot) -> Void) {
        actions(CharacterListRobot(app: app))
    }
}
```

#### Robot Implementation

Each Robot has its own copy of accessibility identifiers (black-box testing principle):

```swift
import XCTest

struct CharacterListRobot: RobotContract {
    let app: XCUIApplication
}

// MARK: - Actions

extension CharacterListRobot {
    @discardableResult
    func tapCharacter(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let identifier = AccessibilityIdentifier.row(id: id)
        let row = app.descendants(matching: .any)[identifier].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
        row.tap()
        return self
    }

    @discardableResult
    func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
        backButton.tap()
        return self
    }
}

// MARK: - Verifications

extension CharacterListRobot {
    @discardableResult
    func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}
```

#### E2E Test Example

```swift
import XCTest

nonisolated final class CharacterFlowE2ETests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCharacterBrowsingFlow() throws {
        let app = launch()

        home(app: app) { robot in
            robot.tapCharacterButton()
        }

        characterList(app: app) { robot in
            robot.tapCharacter(id: 1)
        }

        characterDetail(app: app) { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        characterList(app: app) { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        home(app: app) { robot in
            robot.verifyIsVisible()
        }
    }
}
```

#### Robot Pattern Rules

- **`nonisolated` on test class** - Required to avoid actor isolation conflicts with XCTestCase
- **`@MainActor` on test methods** - Add when tests interact with UI (XCUIApplication)
- **`RobotContract` protocol** - Base protocol with `app: XCUIApplication`
- **Actions section** - Methods that perform UI interactions (tap, swipe, type)
- **Verifications section** - Methods that assert UI state (verifyIsVisible, verifyText)
- **`@discardableResult`** - All robot methods return `Self` for chaining
- **`#filePath` and `line`** - Pass through for accurate test failure locations
- **Private AccessibilityIdentifier** - Each Robot has its own copy of identifiers
- **`.firstMatch`** - Use when multiple elements may match an identifier

### Mocks

Mock names must end with `Mock` suffix. Place mocks based on their visibility:

| Location | Visibility | Usage |
|----------|------------|-------|
| `Mocks/` (framework) | Public | Mocks used by other modules (e.g., `ChallengeNetworkingMocks`) |
| `Tests/Mocks/` | Internal | Mocks only used within the test target |

```
FeatureName/
├── Mocks/                    # Public mocks (ChallengeFeatureNameMocks framework)
│   └── {Name}RepositoryMock.swift
└── Tests/
    ├── Mocks/                # Internal test-only mocks
    │   └── {Name}DataSourceMock.swift
    └── {Name}UseCaseTests.swift
```

For mock implementation patterns, see the skills: `/datasource`, `/repository`, `/usecase`.

### Stubs (Test Data for Domain Models)

Use the **stub pattern** to create test data for **Domain Models only**. Stubs are extensions on domain models that provide factory methods with sensible defaults.

**Location:** `Tests/Stubs/`

```
FeatureName/
└── Tests/
    ├── Stubs/                    # Test data factories for Domain Models
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
        email: String = "john@example.com"
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
- **Only for Domain Models** (not DTOs)

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

### JSON Fixtures (Test Data for DTOs)

**DTOs use JSON files** that replicate real server responses instead of stub extensions. This ensures tests validate the actual API contract and catch deserialization issues.

- **JSON files location:** `Tests/Fixtures/`
- **Helper location:** `ChallengeCoreMocks` (`Bundle+JSON.swift`)

For detailed documentation on JSON fixtures and usage examples, see the `/datasource` skill.

---

## Style Guide

All generated code **must** follow these rules. Based on the [Airbnb Swift Style Guide](https://github.com/airbnb/swift).

### Formatting

| Rule | Value |
|------|-------|
| Maximum line width | 140 characters |
| Trailing commas | Not used |
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
// RIGHT - Mock as suffix for types
class UserRepositoryMock { }
class HTTPClientMock { }

// WRONG - Mock as prefix (PROHIBITED)
class MockUserRepository { }
enum MockError { }
struct MockData { }
```

**Mock variable naming rule:** Variables holding mock instances must also use the `Mock` suffix:

```swift
// RIGHT - Variable with Mock suffix
let httpClientMock = HTTPClientMock()
let repositoryMock = UserRepositoryMock()
var dataSourceMock: CharacterDataSourceMock

// WRONG - Variable without Mock suffix or with mock prefix
let httpClient = HTTPClientMock()
let mockRepository = UserRepositoryMock()
var dataSource: CharacterDataSourceMock
```

**Identifier naming rule:** Prefer `identifier` over `id` for variable and parameter names:

```swift
// RIGHT - Use 'identifier'
func getCharacter(identifier: Int) -> Character
case detail(identifier: Int)
let characterIdentifier = character.id

// WRONG - Avoid 'id' as variable/parameter name
func getCharacter(id: Int) -> Character
case detail(id: Int)
let characterId = character.id
```

> **Note:** Model properties from APIs may use `id` (e.g., `character.id`), but local variables and parameters should use `identifier`.

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
// WRONG - Using type name in static references
static func == (lhs: MyType, rhs: MyType) -> Bool

// RIGHT - Use Self
static func == (lhs: Self, rhs: Self) -> Bool
```

```swift
// WRONG - let/var inside each tuple element
case (.loaded(let lhsData), .loaded(let rhsData)):

// RIGHT - let/var outside the tuple
case let (.loaded(lhsData), .loaded(rhsData)):
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
// RIGHT - Protocol injection with contract type
final class UserListViewModel {
  private let useCase: GetUsersUseCaseContract

  init(useCase: GetUsersUseCaseContract) {
    self.useCase = useCase
  }
}

// WRONG - Concrete type (implementation exposed)
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

> **Note:** For SwiftUI Previews documentation, see `/view` skill.

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
| `/datasource` | Create DataSources (RemoteDataSource for REST APIs, MemoryDataSource for in-memory storage) |
| `/repository` | Create Repositories with optional local-first caching policy |
| `/usecase` | Create UseCases that encapsulate business logic |
| `/viewmodel` | Create ViewModels with ViewState pattern |
| `/view` | Create SwiftUI Views that use ViewModels |
| `/router` | Create Router for navigation with RouterContract injection |
| `/dependencyInjection` | Create Containers and feature entry points |

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
ObservableObject (use @Observable instead)
@Published (use @Observable instead)
```

### Required Patterns

```swift
// Always use
async/await for asynchronous code
@Observable for state management (iOS 17+)
actors for background work (opt out of MainActor)
nonisolated for types used inside actors
protocols (contracts) for dependency injection
Contract suffix for protocols (e.g., UserRepositoryContract)
Mock suffix for mocks (e.g., UserRepositoryMock)
Alphabetically ordered imports
```

