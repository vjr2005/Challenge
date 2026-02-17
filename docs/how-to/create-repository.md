# How To: Create Repository

Create a Repository that abstracts data access, transforms DTOs to Domain models, and optionally implements caching strategies.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- DataSources created (see [Create DataSource](create-datasource.md))

## Scope & Boundaries

> **Important:** The `/repository` skill is responsible **only** for Domain and Data layer files (models, errors, contracts, mappers, repositories, mocks, stubs, tests). It does **NOT** modify Feature entry points (`{Feature}Feature.swift`), Containers (`{Feature}Container.swift`), AppContainer, or Tuist modules. Any changes to these files must be delegated to the `/feature` skill, which owns the wiring of dependencies into the feature.

## Repository types

| Type | DataSources | Use case |
|------|-------------|----------|
| Remote only | `RemoteDataSource` | Simple API consumption, no caching |
| Local only (persistent) | `LocalDataSource` | UserDefaults-backed storage (e.g., recent searches) |
| Both (with cache) | `RemoteDataSource` + `EntityDataSource` (SwiftData) | Two-level caching with configurable policy |

## File structure

```
Features/{Feature}/
├── Sources/
│   ├── Domain/
│   │   ├── Errors/
│   │   │   └── {Feature}Error.swift              # Domain error (typed throws)
│   │   ├── Models/
│   │   │   └── {Name}.swift                      # Domain model
│   │   └── Repositories/
│   │       └── {Name}RepositoryContract.swift    # Contract (protocol)
│   └── Data/
│       ├── DataSources/                          # See /datasource skill
│       ├── DTOs/                                 # See /datasource skill
│       ├── Mappers/
│       │   ├── {Name}Mapper.swift                # DTO → Domain mapping
│       │   └── {Name}ErrorMapper.swift           # APIError → Domain error
│       └── Repositories/
│           └── {Name}Repository.swift            # Implementation
└── Tests/
    ├── Unit/Data/
    │   ├── {Name}RepositoryTests.swift
    │   └── Mappers/
    │       └── {Name}ErrorMapperTests.swift
    ├── Unit/Domain/Errors/
    │   └── {Feature}ErrorTests.swift
    └── Shared/
        ├── Mocks/
        │   └── {Name}RepositoryMock.swift
        └── Stubs/
            └── {Name}+Stub.swift
```

---

## Workflow

### Step 1 — Identify Existing DataSources

Before creating a Repository, scan the feature's `Sources/Data/DataSources/` directory to discover what already exists.

- **DataSources found?** → Go to Step 2
- **No DataSources found?** → Create the DataSource first using the `/datasource` skill, then return here.

### Step 2 — Select Target DataSource

Possible combinations:

| Scenario | DataSources | Next step |
|----------|-------------|-----------|
| Remote only | `RemoteDataSource` only | → Step 3a |
| Local only (persistent) | `LocalDataSource` (UserDefaults) only | → Step 3b |
| Both (cached) | `RemoteDataSource` + `EntityDataSource` (SwiftData) | → Step 3c |

---

## Common components (all types)

### Domain Model

> *"The basic symptom of an Anemic Domain Model is that at first blush it looks like the real thing... but there is hardly any behavior on these objects, making them little more than bags of getters and setters."*
> — Martin Fowler, [Anemic Domain Model](https://martinfowler.com/bliki/AnemicDomainModel.html)

Domain models **should have behavior** — unlike DTOs (which are intentionally anemic), domain models can include factory methods, computed properties, and business rules.

Create `Sources/Domain/Models/{Name}.swift`:

```swift
struct {Name}: Equatable {
	let id: Int
	let name: String
	let items: [Item]

	static func empty() -> {Name} {
		{Name}(id: 0, name: "", items: [])
	}

	var totalValue: Decimal {
		items.reduce(0) { $0 + $1.price }
	}
}
```

**Rules:** `Domain/Models/`, internal visibility, `Equatable`, `let` properties, may include factory methods / computed properties / business rules. No persistence, presentation, or serialization logic.

### Domain Error

Create `Sources/Domain/Errors/{Feature}Error.swift`:

```swift
import ChallengeResources
import Foundation

public enum {Feature}Error: Error, Equatable, LocalizedError {
	case loadFailed(description: String = "")
	case notFound(identifier: Int)

	public static func == (lhs: {Feature}Error, rhs: {Feature}Error) -> Bool {
		switch (lhs, rhs) {
		case (.loadFailed, .loadFailed): true
		case let (.notFound(lhsId), .notFound(rhsId)): lhsId == rhsId
		default: false
		}
	}

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			"{feature}Error.loadFailed".localized()
		case .notFound(let identifier):
			"{feature}Error.notFound %lld".localized(identifier)
		}
	}
}

extension {Feature}Error: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .loadFailed(let description): description
		case .notFound(let identifier): "notFound(identifier: \(identifier))"
		}
	}
}
```

**Rules:** Public, `Error` + `Equatable` + `LocalizedError`, custom `==` ignores `description`, `CustomDebugStringConvertible` for tracker, localized strings from Resources.

### DTO → Domain Mapper

Create `Sources/Data/Mappers/{Name}Mapper.swift`:

```swift
import ChallengeCore

struct {Name}Mapper: MapperContract {
	func map(_ input: {Name}DTO) -> {Name} {
		{Name}(id: input.id, name: input.name)
	}
}
```

Pure stateless structs, `MapperContract` from `ChallengeCore`. Used as concrete types in repositories (not injected). Composable: mappers can delegate to other mappers.

### Error Mapper

Create `Sources/Data/Mappers/{Name}ErrorMapper.swift`:

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}ErrorMapperInput {
	let error: any Error
	let identifier: Int
}

struct {Name}ErrorMapper: MapperContract {
	func map(_ input: {Name}ErrorMapperInput) -> {Feature}Error {
		guard let apiError = input.error as? APIError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch apiError {
		case .notFound:
			.notFound(identifier: input.identifier)
		case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
			.loadFailed(description: String(describing: apiError))
		}
	}
}
```

---

## Step 3a: Remote Only Repository

### Contract

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
protocol {Name}RepositoryContract: Sendable {
	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name}
}
```

**Naming:** `get{Name}` (singular), `get{Name}sPage` (paginated list), `search{Name}sPage` (search). Separate contracts per ISP when concerns differ.

### Implementation

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}Repository: {Name}RepositoryContract {
	private let remoteDataSource: {Name}RemoteDataSourceContract
	private let mapper = {Name}Mapper()
	private let errorMapper = {Name}ErrorMapper()

	init(remoteDataSource: {Name}RemoteDataSourceContract) {
		self.remoteDataSource = remoteDataSource
	}

	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
		do {
			let dto = try await remoteDataSource.fetch{Name}(identifier: identifier)
			return mapper.map(dto)
		} catch {
			throw errorMapper.map({Name}ErrorMapperInput(error: error, identifier: identifier))
		}
	}
}
```

### Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import ChallengeCore
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
	var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
	private(set) var getCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
		getCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}
```

### Tests

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
	@Test("Gets model from remote data source")
	func getsModelFromRemoteDataSource() async throws {
		// Given
		let expected = {Name}.stub()
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .success(.stub())
		let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

		// When
		let value = try await sut.get{Name}(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test("Calls remote data source with correct identifier")
	func callsRemoteDataSourceWithCorrectIdentifier() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .success(.stub())
		let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

		// When
		_ = try await sut.get{Name}(identifier: 42)

		// Then
		#expect(remoteDataSourceMock.fetchCallCount == 1)
		#expect(remoteDataSourceMock.lastFetchedIdentifier == 42)
	}

	@Test("Maps API error to domain error")
	func mapsAPIErrorToDomainError() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .failure(.notFound)
		let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

		// When / Then
		await #expect(throws: {Feature}Error.notFound(identifier: 1)) {
			_ = try await sut.get{Name}(identifier: 1)
		}
	}

	@Test("Maps generic error to loadFailed")
	func mapsGenericErrorToLoadFailed() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .failure(GenericTestError.unknown)
		let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

		// When / Then
		await #expect(throws: {Feature}Error.loadFailed()) {
			_ = try await sut.get{Name}(identifier: 1)
		}
	}
}

private enum GenericTestError: Error {
	case unknown
}
```

> **Note:** HTTP error mapping tests (404 → notFound, 500 → loadFailed, etc.) belong in `{Name}ErrorMapperTests`, not in repository tests. Repository tests only verify data access behavior and generic error propagation.

### Checklist

- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/` (typed throws, `LocalizedError`, custom `Equatable`, `CustomDebugStringConvertible`)
- [ ] Contract in `Domain/Repositories/` (typed throws, `Sendable`)
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Error Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects RemoteDataSource, uses Mapper + Error Mapper)
- [ ] Mock in `Tests/Shared/Mocks/`
- [ ] Mapper tests, Error Mapper tests, Repository tests
- [ ] Localized strings for error messages

---

## Step 3b: Local Only Repository

### Contract

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
protocol {Name}RepositoryContract: Sendable {
	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name}
	func save{Name}(_ model: {Name}) async
}
```

### Implementation

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
struct {Name}Repository: {Name}RepositoryContract {
	private let localDataSource: {Name}LocalDataSourceContract
	private let mapper = {Name}Mapper()

	init(localDataSource: {Name}LocalDataSourceContract) {
		self.localDataSource = localDataSource
	}

	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
		guard let dto = await localDataSource.get{Name}(identifier: identifier) else {
			throw .notFound(identifier: identifier)
		}
		return mapper.map(dto)
	}

	func save{Name}(_ model: {Name}) async {
		await localDataSource.save{Name}(model.toDTO())
	}
}
```

### Domain to DTO Mapping

```swift
extension {Name} {
	func toDTO() -> {Name}DTO {
		{Name}DTO(id: id, name: name)
	}
}
```

### Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
	var getResult: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
	private(set) var getCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var saveCallCount = 0
	private(set) var lastSavedModel: {Name}?

	func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
		getCallCount += 1
		lastRequestedIdentifier = identifier
		return try getResult.get()
	}

	func save{Name}(_ model: {Name}) async {
		saveCallCount += 1
		lastSavedModel = model
	}
}
```

### Tests

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
	@Test("Gets model from local data source")
	func getsModelFromLocalDataSource() async throws {
		// Given
		let expected = {Name}.stub()
		let localDataSourceMock = {Name}LocalDataSourceMock()
		localDataSourceMock.itemToReturn = .stub()
		let sut = {Name}Repository(localDataSource: localDataSourceMock)

		// When
		let value = try await sut.get{Name}(identifier: expected.id)

		// Then
		#expect(value == expected)
	}

	@Test("Throws notFound when item does not exist")
	func throwsNotFoundWhenItemDoesNotExist() async throws {
		// Given
		let localDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(localDataSource: localDataSourceMock)

		// When / Then
		await #expect(throws: {Feature}Error.notFound(identifier: 999)) {
			_ = try await sut.get{Name}(identifier: 999)
		}
	}

	@Test("Saves model to local data source")
	func savesModelToLocalDataSource() async {
		// Given
		let model = {Name}.stub()
		let localDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(localDataSource: localDataSourceMock)

		// When
		await sut.save{Name}(model)

		// Then
		#expect(localDataSourceMock.saveCallCount == 1)
		#expect(localDataSourceMock.saveLastValue == model.toDTO())
	}
}
```

### Checklist

- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/`
- [ ] Contract in `Domain/Repositories/` (typed throws, `Sendable`)
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects LocalDataSource, uses Mapper)
- [ ] Domain-to-DTO mapping (for saving)
- [ ] Mock in `Tests/Shared/Mocks/`
- [ ] Tests

---

## Step 3c: Cached Repository (Remote + Local)

Choose the cache policy:

| Policy | Behavior | Reference |
|--------|----------|-----------|
| **localFirst** | Cache → Remote (if miss) → Save to cache | Single fixed strategy |
| **remoteFirst** | Remote → Save to cache → Cache (if error) | Single fixed strategy |
| **noCache** | Remote only, no cache interaction | Single fixed strategy |
| **All (configurable)** | Accept `CachePolicy` parameter, implement all three | **Recommended** |

`CachePolicy` is defined in `ChallengeCore` and shared across features:

```swift
public enum CachePolicy {
	case localFirst   // Cache → Remote (if miss) → Save to cache
	case remoteFirst  // Remote → Save to cache → Cache (if error)
	case noCache      // Remote only, no cache interaction
}
```

### Contract (All configurable)

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
import ChallengeCore

protocol {Name}RepositoryContract: Sendable {
	func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

### Implementation (All configurable)

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}Repository: {Name}RepositoryContract {
	private let remoteDataSource: {Name}RemoteDataSourceContract
	private let volatileDataSource: {Name}LocalDataSourceContract
	private let persistenceDataSource: {Name}LocalDataSourceContract
	private let mapper = {Name}Mapper()
	private let errorMapper = {Name}ErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: {Name}RemoteDataSourceContract,
		volatile: {Name}LocalDataSourceContract,
		persistence: {Name}LocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.volatileDataSource = volatile
		self.persistenceDataSource = persistence
	}

	func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetch{Name}(identifier: identifier) },
			getFromVolatile: { await volatileDataSource.get{Name}(identifier: identifier) },
			getFromPersistence: { await persistenceDataSource.get{Name}(identifier: identifier) },
			saveToVolatile: { await volatileDataSource.save{Name}($0) },
			saveToPersistence: { await persistenceDataSource.save{Name}($0) },
			mapper: { mapper.map($0) },
			errorMapper: { errorMapper.map({Name}ErrorMapperInput(error: $0, identifier: identifier)) }
		)
	}
}
```

> **Note:** `CachePolicyExecutor` coordinates L1 (volatile, in-memory SwiftData) and L2 (persistence, on-disk SwiftData): reads try L1 → L2 (promoting to L1) → remote, writes save to both levels. Cache strategy logic is tested once in `CachePolicyExecutorTests`.

### Mock (All configurable)

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import ChallengeCore
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
	var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
	private(set) var getCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastCachePolicy: CachePolicy?

	func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
		getCallCount += 1
		lastRequestedIdentifier = identifier
		lastCachePolicy = cachePolicy
		return try result.get()
	}
}
```

### Tests (All configurable)

Cache strategy logic is tested centrally in `CachePolicyExecutorTests`. Repository tests focus on **wiring** (correct data source calls, mapper usage), **cache wiring**, and **error mapping**.

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
	// MARK: - Remote Fetch

	@Test("Fetches from remote and maps to domain model")
	func fetchesFromRemoteAndMapsToDomainModel() async throws {
		// Given
		let remoteDTO: {Name}DTO = try loadJSON("{name}")
		let expected = {Name}.stub()
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .success(remoteDTO)
		let volatileDataSourceMock = {Name}LocalDataSourceMock()
		let persistenceDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)

		// When
		let value = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)

		// Then
		#expect(value == expected)
		#expect(remoteDataSourceMock.fetchCallCount == 1)
	}

	// MARK: - Cache Wiring

	@Test("Returns cached data from volatile cache")
	func returnsCachedDataFromVolatileCache() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		let volatileDataSourceMock = {Name}LocalDataSourceMock()
		await volatileDataSourceMock.setItemToReturn(try loadJSON("{name}"))
		let persistenceDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)

		// When
		_ = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(remoteDataSourceMock.fetchCallCount == 0)
	}

	@Test("Falls back to persistence cache on volatile miss")
	func fallsBackToPersistenceCacheOnVolatileMiss() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		let volatileDataSourceMock = {Name}LocalDataSourceMock()
		let persistenceDataSourceMock = {Name}LocalDataSourceMock()
		await persistenceDataSourceMock.setItemToReturn(try loadJSON("{name}"))
		let sut = {Name}Repository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)

		// When
		_ = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(remoteDataSourceMock.fetchCallCount == 0)
	}

	@Test("Saves to both caches after successful remote fetch")
	func savesToBothCachesAfterRemoteFetch() async throws {
		// Given
		let remoteDTO: {Name}DTO = try loadJSON("{name}")
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .success(remoteDTO)
		let volatileDataSourceMock = {Name}LocalDataSourceMock()
		let persistenceDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)

		// When
		_ = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(await volatileDataSourceMock.saveCallCount == 1)
		#expect(await persistenceDataSourceMock.saveCallCount == 1)
	}

	// MARK: - Error Handling

	@Test("Maps API error to domain error")
	func mapsAPIErrorToDomainError() async throws {
		// Given
		let remoteDataSourceMock = {Name}RemoteDataSourceMock()
		remoteDataSourceMock.result = .failure(.notFound)
		let volatileDataSourceMock = {Name}LocalDataSourceMock()
		let persistenceDataSourceMock = {Name}LocalDataSourceMock()
		let sut = {Name}Repository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)

		// When / Then
		await #expect(throws: {Feature}Error.notFound(identifier: 1)) {
			_ = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)
		}
	}
}
```

### Checklist (All configurable)

- [ ] Import `ChallengeCore` (provides `CachePolicy`, `CachePolicyExecutor`, and `MapperContract`)
- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/` (typed throws, `LocalizedError`, custom `Equatable`, `CustomDebugStringConvertible`)
- [ ] Contract in `Domain/Repositories/` with `cachePolicy: CachePolicy` parameter
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Error Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects both volatile + persistence DataSources, uses Mapper + Error Mapper)
- [ ] Delegate to `CachePolicyExecutor` for cache strategy execution (with `errorMapper` closure)
- [ ] Mock in `Tests/Shared/Mocks/` (tracks `cachePolicy`)
- [ ] Mapper tests, Error Mapper tests
- [ ] Tests for cache wiring (volatile hit, persistence fallback, save to both)
- [ ] Tests for error handling
- [ ] Localized strings for error messages

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Domain Error | **public** | `Sources/Domain/Errors/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| Mapper | internal | `Sources/Data/Mappers/` |
| Error Mapper | internal | `Sources/Data/Mappers/` |
| Mock | internal | `Tests/Shared/Mocks/` |

## Add localized strings

Add to `Shared/Resources/Sources/Resources/Localizable.xcstrings`:

```json
"{feature}Error.loadFailed": "Failed to load data",
"{feature}Error.notFound %lld": "Item with ID %lld not found"
```

## Generate and verify

```bash
mise x -- tuist test --skip-ui-tests
```

## Next steps

- [Create UseCase](create-usecase.md) — Create business logic using this Repository

## See also

- [Create DataSource](create-datasource.md)
- [Project Structure](../ProjectStructure.md)
