# UserDefaults DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{storageKey}` (UserDefaults key string).

---

### {Name}LocalDataSourceContract.swift — `Sources/Data/DataSources/Local/`

```swift
protocol {Name}LocalDataSourceContract: Sendable {
	func getItems() -> [String]
	func saveItem(_ item: String)
	func deleteItem(_ item: String)
}
```

Rules: `Sendable`, **synchronous** (no `async`). Adapt return types and parameters to the specific data being stored.

### {Name}LocalDataSource.swift — `Sources/Data/DataSources/Local/`

```swift
import Foundation

struct {Name}LocalDataSource: {Name}LocalDataSourceContract {
	private nonisolated(unsafe) let userDefaults: UserDefaults
	private let key = "{storageKey}"

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getItems() -> [String] {
		userDefaults.stringArray(forKey: key) ?? []
	}

	func saveItem(_ item: String) {
		var items = getItems()
		// Remove duplicates (case-insensitive)
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		items.insert(item, at: 0)
		// Enforce limit
		if items.count > 5 {
			items = Array(items.prefix(5))
		}
		userDefaults.set(items, forKey: key)
	}

	func deleteItem(_ item: String) {
		var items = getItems()
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		userDefaults.set(items, forKey: key)
	}
}
```

Adapt business rules (deduplication, ordering, limits) to the specific use case.

### {Name}LocalDataSourceMock.swift — `Tests/Shared/Mocks/`

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}LocalDataSourceMock: {Name}LocalDataSourceContract, @unchecked Sendable {
	var items: [String] = []
	private(set) var getItemsCallCount = 0
	private(set) var saveItemCallCount = 0
	private(set) var lastSavedItem: String?
	private(set) var deleteItemCallCount = 0
	private(set) var lastDeletedItem: String?

	func getItems() -> [String] {
		getItemsCallCount += 1
		return items
	}

	func saveItem(_ item: String) {
		saveItemCallCount += 1
		lastSavedItem = item
	}

	func deleteItem(_ item: String) {
		deleteItemCallCount += 1
		lastDeletedItem = item
	}
}
```

### {Name}LocalDataSourceTests.swift — `Tests/Unit/Data/`

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}LocalDataSourceTests {
	// MARK: - Properties

	private let sut: {Name}LocalDataSource

	// MARK: - Init

	init() {
		let suite = UserDefaults(suiteName: "\(type(of: self))")!
		suite.removePersistentDomain(forName: "\(type(of: self))")
		sut = {Name}LocalDataSource(userDefaults: suite)
	}

	// MARK: - Get

	@Test("Returns empty array initially")
	func returnsEmptyArrayInitially() {
		#expect(sut.getItems().isEmpty)
	}

	// MARK: - Save

	@Test("Saves and retrieves item")
	func savesAndRetrievesItem() {
		// When
		sut.saveItem("test")

		// Then
		#expect(sut.getItems() == ["test"])
	}

	@Test("Most recent item is first")
	func mostRecentItemIsFirst() {
		// Given
		sut.saveItem("first")

		// When
		sut.saveItem("second")

		// Then
		#expect(sut.getItems() == ["second", "first"])
	}

	@Test("Deduplicates case-insensitively")
	func deduplicatesCaseInsensitively() {
		// Given
		sut.saveItem("Test")

		// When
		sut.saveItem("test")

		// Then
		#expect(sut.getItems() == ["test"])
	}

	@Test("Enforces maximum limit")
	func enforcesMaximumLimit() {
		// Given
		for i in 1...6 {
			sut.saveItem("item\(i)")
		}

		// Then
		#expect(sut.getItems().count == 5)
		#expect(sut.getItems().first == "item6")
	}

	// MARK: - Delete

	@Test("Deletes item case-insensitively")
	func deletesItemCaseInsensitively() {
		// Given
		sut.saveItem("Test")

		// When
		sut.deleteItem("test")

		// Then
		#expect(sut.getItems().isEmpty)
	}

	// MARK: - Persistence

	@Test("Persists across instances")
	func persistsAcrossInstances() {
		// Given
		let suite = UserDefaults(suiteName: "persistence_test")!
		suite.removePersistentDomain(forName: "persistence_test")
		let first = {Name}LocalDataSource(userDefaults: suite)
		first.saveItem("persisted")

		// When
		let second = {Name}LocalDataSource(userDefaults: suite)

		// Then
		#expect(second.getItems() == ["persisted"])
	}
}
```

Each test uses a dedicated `UserDefaults` suite to avoid cross-test contamination. The `init` clears the suite before each test.
