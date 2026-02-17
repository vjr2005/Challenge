# SwiftData EntityDataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{name}` (snake_case).

Used for two-level caching (volatile + persistence): same `EntityDataSource` type, different `ModelContainer` configurations (in-memory vs on-disk).

---

### {Name}Entity.swift — `Sources/Data/Entities/`

```swift
import Foundation
import SwiftData

@Model
nonisolated final class {Name}Entity {
	@Attribute(.unique) var identifier: Int
	var name: String
	// ... other properties

	init(identifier: Int, name: String) {
		self.identifier = identifier
		self.name = name
	}
}
```

Rules: `@Model`, `nonisolated final class`, `@Attribute(.unique)` on identifier. Use `@Relationship(deleteRule: .cascade, inverse: \ChildEntity.parent)` for parent-child relationships.

### {Name}ModelContainer.swift — `Sources/Data/Entities/`

```swift
import Foundation
import SwiftData

enum {Name}ModelContainer {
	private static let schema = Schema([
		{Name}Entity.self
	])

	static func create(inMemoryOnly: Bool = false) -> ModelContainer {
		do {
			let configuration = ModelConfiguration("{Name}Store", schema: schema, isStoredInMemoryOnly: inMemoryOnly)
			return try ModelContainer(for: schema, configurations: [configuration])
		} catch {
			fatalError("Failed to create {Name}ModelContainer: \(error)")
		}
	}
}
```

Rules: Factory enum, single schema definition. **Named `ModelConfiguration` is mandatory** — each module must use a unique store name (e.g., `"{Name}Store"`) to avoid schema collisions when multiple modules use SwiftData. `inMemoryOnly: true` for volatile (L1), `false` for persistence (L2). `fatalError` in catch (untestable but acceptable at container level).

### {Name}LocalDataSourceContract.swift — `Sources/Data/DataSources/Local/`

```swift
protocol {Name}LocalDataSourceContract: Actor {
	func get{Name}(identifier: Int) async -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO) async
}
```

Rules: `: Actor`, return optionals for get. Same contract for both volatile and persistence data sources.

### {Name}EntityDataSource.swift — `Sources/Data/DataSources/Local/`

```swift
import Foundation
import SwiftData

@ModelActor
actor {Name}EntityDataSource: {Name}LocalDataSourceContract {
	private let entityMapper = {Name}EntityMapper()
	private let entityDTOMapper = {Name}EntityDTOMapper()

	func get{Name}(identifier: Int) -> {Name}DTO? {
		let descriptor = FetchDescriptor<{Name}Entity>(
			predicate: #Predicate { $0.identifier == identifier }
		)
		guard let entity = try? modelContext.fetch(descriptor).first else { return nil }
		return entityDTOMapper.map(entity)
	}

	func save{Name}(_ item: {Name}DTO) {
		let identifier = item.id
		let descriptor = FetchDescriptor<{Name}Entity>(
			predicate: #Predicate { $0.identifier == identifier }
		)
		if let existing = try? modelContext.fetch(descriptor).first {
			modelContext.delete(existing)
		}
		let entity = entityMapper.map(item)
		modelContext.insert(entity)
		try? modelContext.save()
	}
}
```

Rules: `@ModelActor` provides automatic actor isolation + `modelContext`. Uses Entity ↔ DTO mappers. For upsert: delete existing before insert.

### Entity Mappers — `Sources/Data/Mappers/`

```swift
import ChallengeCore

struct {Name}EntityMapper: MapperContract {
	nonisolated func map(_ input: {Name}DTO) -> {Name}Entity {
		{Name}Entity(identifier: input.id, name: input.name)
	}
}

struct {Name}EntityDTOMapper: MapperContract {
	nonisolated func map(_ input: {Name}Entity) -> {Name}DTO {
		{Name}DTO(id: input.identifier, name: input.name)
	}
}
```

Rules: `nonisolated func map`, `MapperContract` from `ChallengeCore`. Sort collections by identifier when mapping from entity to DTO (SwiftData relationships don't guarantee order).

### {Name}LocalDataSourceMock.swift — `Tests/Shared/Mocks/`

```swift
import Foundation

@testable import Challenge{Feature}

actor {Name}LocalDataSourceMock: {Name}LocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var itemToReturn: {Name}DTO?

	func setItemToReturn(_ item: {Name}DTO?) {
		itemToReturn = item
	}

	// MARK: - Call Tracking

	private(set) var get{Name}CallCount = 0
	private(set) var save{Name}CallCount = 0
	private(set) var save{Name}LastValue: {Name}DTO?

	// MARK: - {Name}LocalDataSourceContract

	func get{Name}(identifier: Int) -> {Name}DTO? {
		get{Name}CallCount += 1
		return itemToReturn
	}

	func save{Name}(_ item: {Name}DTO) {
		save{Name}CallCount += 1
		save{Name}LastValue = item
	}
}
```

Actor mock: `private(set)` on configurable returns with setter methods. Tests use `await` for all property reads and setter calls.

### Container Wiring — `Sources/{Feature}Container.swift`

```swift
let volatileContainer = {Name}ModelContainer.create(inMemoryOnly: true)
let persistenceContainer = {Name}ModelContainer.create()
let volatileDataSource = {Name}EntityDataSource(modelContainer: volatileContainer)
let persistenceDataSource = {Name}EntityDataSource(modelContainer: persistenceContainer)
self.repository = {Name}Repository(
    remoteDataSource: remoteDataSource,
    volatile: volatileDataSource,
    persistence: persistenceDataSource
)
```

Two `ModelContainer` instances → two `EntityDataSource` instances → both injected into repository as `volatile:` and `persistence:`.

### {Name}EntityDataSourceTests.swift — `Tests/Unit/Data/`

Tests use in-memory `ModelContainer` for isolation:

```swift
struct {Name}EntityDataSourceTests {
	private let sut: {Name}EntityDataSource

	init() {
		let container = {Name}ModelContainer.create(inMemoryOnly: true)
		sut = {Name}EntityDataSource(modelContainer: container)
	}

	@Test("Returns nil when not found")
	func returnsNil() async {
		let result = await sut.get{Name}(identifier: 999)
		#expect(result == nil)
	}

	@Test("Returns item after saving")
	func returnsAfterSaving() async throws {
		let dto: {Name}DTO = try loadJSON("{name}")
		await sut.save{Name}(dto)
		let result = await sut.get{Name}(identifier: dto.id)
		#expect(result == dto)
	}
}
```
