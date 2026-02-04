# Testing

## Test Types

| Type | Framework | Location |
|------|-----------|----------|
| Unit Tests | Swift Testing | `*/Tests/Unit/` |
| Snapshot Tests | SnapshotTesting | `*/Tests/Snapshots/` |
| UI Tests | XCTest | `App/Tests/UI/` |

## Test Structure

Tests follow Given/When/Then structure:

```swift
@Test("Fetches characters from repository")
func fetchesCharacters() async throws {
    // Given
    let sut = GetCharactersUseCase(repository: repositoryMock)

    // When
    let result = try await sut.execute(page: 1)

    // Then
    #expect(result.characters.count == 2)
}
```

## Test Doubles

The project uses **Mocks** to isolate units under test. Mocks are located in:

| Location | Scope | Purpose |
|----------|-------|---------|
| `Libraries/Core/Mocks/` | Public | Shared mocks for Core protocols |
| `Libraries/Networking/Mocks/` | Public | Shared mocks for Networking protocols |
| `*/Tests/Shared/Mocks/` | Internal | Module-specific test mocks |

### Example Mock

```swift
final class CharacterRepositoryMock: CharacterRepositoryContract {
    var getCharactersResult: Result<CharacterPage, Error> = .success(.stub())

    func getCharacters(page: Int) async throws -> CharacterPage {
        try getCharactersResult.get()
    }
}
```

### Test Data

| Location | Purpose |
|----------|---------|
| `*/Tests/Shared/Stubs/` | Domain model test data (`.stub()` extensions) |
| `*/Tests/Shared/Fixtures/` | JSON files for DTO testing |

## UI Tests

UI tests use [SwiftMockServer](https://github.com/nicklama/SwiftMockServer) to run a local HTTP mock server. The `UITestCase` base class manages the server lifecycle and passes the base URL to the app via the `API_BASE_URL` environment variable.

### Scenarios

Mock server configurations are extracted into reusable methods on `UITestCase`:

| Type | Purpose | Example |
|------|---------|---------|
| **Initial** | Configure all routes before `launch()` | `givenCharacterListSucceeds()` |
| **Recovery** | Override specific routes mid-test for retry flows | `givenCharacterListRecovers()` |

Scenarios live in `App/Tests/Shared/Scenarios/UITestCase+Scenarios.swift`. See the `/ui-tests` skill for the full list and implementation details.

### Robot Pattern

Each screen has a Robot struct that encapsulates UI interactions and verifications:

```swift
@MainActor
func testNavigationFlow() async throws {
    // Given
    try await givenCharacterListAndDetailSucceeds()

    // When
    launch()

    // Then
    characterList { robot in
        robot.verifyIsVisible()
        robot.tapCharacter(identifier: 1)
    }
}
```

See the `/ui-tests` skill for Robot implementation details.

## Test Parallelization

Tests run **serially** (parallelization disabled). A benchmark study was conducted and parallelization resulted in **~49% slower** execution times due to simulator cloning overhead and CPU contention.

### Benchmark Results

| Test Type | Serial | Parallel | Change |
|-----------|--------|----------|--------|
| Unit + Snapshot | 0:36 | 0:56 | +55.6% slower |
| UI Tests | 2:17 | 3:21 | +46.7% slower |
| **Total** | **2:53** | **4:17** | **+48.6% slower** |

> Measured on iPhone 17 Pro simulator, Tuist 4.129.0 (February 2026).

### Why Parallelization Is Slower

**Unit + Snapshot Tests:**
The scheme has 12 test targets (7 unit + 5 snapshot), each running in its own xctest process in both serial and parallel modes. The difference is execution strategy:

- **Serial**: The 12 processes run sequentially on the same simulator. The simulator stays "warm" (rendering caches, frameworks already loaded in memory), and each process gets exclusive access to CPU and GPU.
- **Parallel**: The 12 processes run concurrently on a cloned simulator (Clone 1), causing:
  1. **Simulator cloning overhead** (creating Clone 1)
  2. **CPU contention** — 12 processes competing for the same cores
  3. **Rendering contention** — snapshot tests render SwiftUI simultaneously, saturating the graphics pipeline
  4. **Cold caches** on the clone vs warm caches on the original simulator

With only **22s of real execution time** in the baseline, resource contention from running 12 processes concurrently (~20s extra) nearly doubles the time.

**UI Tests:**
Xcode distributes parallel UI tests **by class**, not by method. Tests were split into 8 classes (1 per test) to maximize parallelism, but:

1. Xcode chose to use only **4 clones** (internal decision based on available CPU/RAM)
2. **Booting each clone** (~15s per simulator) costs more time than it saves with only 8 tests
3. **CPU contention** between 4 simulators makes each individual test slower

**Serialization requirements:**
Two test suites required `.serialized` to pass under parallelization:

- **`HTTPClientTests`**: Uses `URLProtocolMock` with global static state (`handlers` dictionary). All tests share the same base URL (`test.example.com`), causing handler collisions when registering in parallel.
- **`CharacterListViewModelTests`**: Debounce tests with `Task.sleep` that are timing-sensitive. CPU pressure from multiple runners causes sleeps to miss their timing targets.

The impact of `.serialized` is minimal (~2-3s), not the main cause of degradation.

### When to Re-evaluate

- When unit/snapshot test execution exceeds **60-90s of real test time**
- When UI tests exceed **15-20 classes** to amortize simulator boot overhead
- When migrating to CI with more powerful runners (more CPU = less relative overhead)

## Coverage

The project achieves **100% code coverage** across all modules.

<img src="screenshots/coverage.png" width="100%">

### Coverage Policy

- All production code must be tested
- Only source targets are measured (mocks and test helpers are excluded)
- Coverage is enforced in CI pipeline
