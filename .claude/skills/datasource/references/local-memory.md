# Memory DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{name}` (snake_case).

---

### {Name}LocalDataSourceContract.swift — `Sources/Data/DataSources/Local/`

Single item caching:

```swift
protocol {Name}LocalDataSourceContract: Sendable {
	func get{Name}(identifier: Int) async -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO) async
}
```

With paginated results:

```swift
protocol {Name}LocalDataSourceContract: Sendable {
	// MARK: - Single Item
	func get{Name}(identifier: Int) async -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO) async

	// MARK: - Paginated Results
	func getPage(_ page: Int) async -> {Name}sResponseDTO?
	func savePage(_ response: {Name}sResponseDTO, page: Int) async
}
```

Rules: `async` (no `throws`), return optionals for get, `identifier` parameter name.

### {Name}MemoryDataSource.swift — `Sources/Data/DataSources/Local/`

```swift
actor {Name}MemoryDataSource: {Name}LocalDataSourceContract {
	private var items: [Int: {Name}DTO] = [:]
	private var pages: [Int: {Name}sResponseDTO] = [:]

	// MARK: - Single Item

	func get{Name}(identifier: Int) -> {Name}DTO? {
		items[identifier]
	}

	func save{Name}(_ item: {Name}DTO) {
		items[item.id] = item
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> {Name}sResponseDTO? {
		pages[page]
	}

	func savePage(_ response: {Name}sResponseDTO, page: Int) {
		pages[page] = response
	}
}
```

Actor methods omit `async` — actor isolation provides it implicitly.

### {Name}LocalDataSourceMock.swift — `Tests/Shared/Mocks/`

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}LocalDataSourceMock: {Name}LocalDataSourceContract, @unchecked Sendable {
	// MARK: - Configurable Returns

	var itemToReturn: {Name}DTO?
	var pageToReturn: {Name}sResponseDTO?

	// MARK: - Call Tracking

	private(set) var get{Name}CallCount = 0
	private(set) var save{Name}CallCount = 0
	private(set) var save{Name}LastValue: {Name}DTO?
	private(set) var getPageCallCount = 0
	private(set) var savePageCallCount = 0
	private(set) var savePageLastResponse: {Name}sResponseDTO?
	private(set) var savePageLastPage: Int?

	// MARK: - {Name}LocalDataSourceContract

	func get{Name}(identifier: Int) -> {Name}DTO? {
		get{Name}CallCount += 1
		return itemToReturn
	}

	func save{Name}(_ item: {Name}DTO) {
		save{Name}CallCount += 1
		save{Name}LastValue = item
	}

	func getPage(_ page: Int) -> {Name}sResponseDTO? {
		getPageCallCount += 1
		return pageToReturn
	}

	func savePage(_ response: {Name}sResponseDTO, page: Int) {
		savePageCallCount += 1
		savePageLastResponse = response
		savePageLastPage = page
	}
}
```

Mock methods omit `async` — Swift allows satisfying `async` protocol requirements with non-async functions.

### {Name}MemoryDataSourceTests.swift — `Tests/Unit/Data/`

```swift
import ChallengeCoreMocks
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}MemoryDataSourceTests {
	@Test("Saves and retrieves item")
	func savesAndRetrievesItem() async throws {
		// Given
		let expected: {Name}DTO = try loadJSON("{name}")
		let sut = {Name}MemoryDataSource()

		// When
		await sut.save{Name}(expected)
		let result = await sut.get{Name}(identifier: expected.id)

		// Then
		#expect(result == expected)
	}

	@Test("Returns nil for non-existent item")
	func returnsNilForNonExistentItem() async {
		// Given
		let sut = {Name}MemoryDataSource()

		// When
		let result = await sut.get{Name}(identifier: 999)

		// Then
		#expect(result == nil)
	}

	@Test("Updates existing item")
	func updatesExistingItem() async throws {
		// Given
		let original: {Name}DTO = try loadJSON("{name}")
		let updated: {Name}DTO = try loadJSON("{name}_updated")
		let sut = {Name}MemoryDataSource()
		await sut.save{Name}(original)

		// When
		await sut.save{Name}(updated)
		let result = await sut.get{Name}(identifier: original.id)

		// Then
		#expect(result == updated)
	}

	@Test("Saves and retrieves page")
	func savesAndRetrievesPage() async throws {
		// Given
		let expected: {Name}sResponseDTO = try loadJSON("{name}s_response")
		let sut = {Name}MemoryDataSource()

		// When
		await sut.savePage(expected, page: 1)
		let result = await sut.getPage(1)

		// Then
		#expect(result == expected)
	}

	@Test("Returns nil for non-existent page")
	func returnsNilForNonExistentPage() async {
		// Given
		let sut = {Name}MemoryDataSource()

		// When
		let result = await sut.getPage(999)

		// Then
		#expect(result == nil)
	}
}

// MARK: - Private

private extension {Name}MemoryDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}
```
