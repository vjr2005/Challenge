---
name: clean-code
description: Detects and removes unused code using Periphery. Use when cleaning up dead code, removing unused functions, or maintaining code hygiene.
invocation: user
---

# Skill: Clean Code

Automated dead code detection and removal using Periphery.

## When to use this skill

- Remove unused code from the project
- Clean up dead code before releases
- Maintain code hygiene periodically

---

## Workflow

Execute the following steps in order:

### Step 1: Run Periphery Scan

If a recent build exists, reuse its index store to skip the build step:

```bash
# Find the index store from the most recent build
INDEX_STORE=$(find ~/Library/Developer/Xcode/DerivedData/Challenge-*/Index.noindex/DataStore -maxdepth 0 2>/dev/null | head -1)

# Skip build if index store exists, otherwise run full scan
if [ -n "$INDEX_STORE" ]; then
  mise x -- periphery scan --skip-build --index-store-path "$INDEX_STORE"
else
  mise x -- periphery scan
fi
```

Analyze the output to identify unused code. The scan retains:
- SwiftUI Previews
- Codable properties
- Public declarations (library code)
- ObjC-annotated declarations

### Step 2: Search for Related Tests and Mocks (BEFORE removing code)

**CRITICAL:** Before removing any code, search for tests and mocks that reference it.

For each unused item reported by Periphery:

```bash
# Search for references in Tests directories
grep -r "functionName\|ClassName" Libraries/**/Tests/
```

**Check these locations:**
- `Tests/Mocks/` - Mock implementations of protocols
- `Tests/Data/` - Repository and DataSource tests
- `Tests/Domain/` - UseCase tests
- `Tests/Presentation/` - ViewModel tests

**If references are found:**
1. Note which test files and mocks need updating
2. Plan to update/remove them along with the production code

### Step 3: Remove Unused Code and Update Tests

For each warning reported by Periphery:

1. **Remove from production code:**
   - Delete the unused declaration
   - If removing from a protocol, also remove from all conforming types

2. **Update related tests and mocks:**
   - Remove the method from mock implementations
   - Delete test cases that test the removed functionality
   - Update any test that calls the removed code

3. **For ViewState Equatable removals:**
   - Create Equatable extension in `Tests/Extensions/` (see below)

### Step 4: Run SwiftLint Auto-fix

After removing code, run SwiftLint to auto-correct formatting issues:

```bash
mise x -- swiftlint --fix --quiet
```

### Step 5: Run Tests (Full Workspace)

Build and execute **all tests** in the workspace:

```bash
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -testPlan Challenge \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

If tests fail:
- Check if failed tests were testing removed code → delete them
- Check if mocks are missing removed methods → update mocks
- If unrelated failure → investigate and fix
- Re-run tests until all pass

### Step 6: Final Verification

Run Periphery again to confirm no unused code remains. The `tuist test` build from the previous step provides a fresh index store:

```bash
INDEX_STORE=$(find ~/Library/Developer/Xcode/DerivedData/Challenge-*/Index.noindex/DataStore -maxdepth 0 2>/dev/null | head -1)
mise x -- periphery scan --skip-build --index-store-path "$INDEX_STORE"
```

Expected output: `* No unused code detected.`

---

## Configuration

Periphery configuration is in `.periphery.yml`:

```yaml
project: {AppName}.xcworkspace
schemes:
  - "{AppName} (Dev)"
  - "{AppName}UITests"
retain_public: true
retain_objc_annotated: true
retain_codable_properties: true
retain_swift_ui_previews: true
```

**Why two schemes:** `{AppName} (Dev)` covers the app and all SPM package dependencies. `{AppName}UITests` covers the native UI test target. Both are analyzed for dead code.

**Why no `exclude_tests`:** With `--skip-build --index-store-path`, Periphery cannot correctly identify SPM test targets from the pre-built index store, causing false positives. Instead, the two schemes explicitly define the analysis scope — only app, SPM source packages, and UI tests are analyzed. SPM test targets are not in any scheme, so they are not analyzed.

### Configuration Options

| Option | Description |
|--------|-------------|
| `retain_public` | Keep public declarations (for libraries) |
| `retain_objc_annotated` | Keep ObjC-annotated declarations |
| `retain_codable_properties` | Keep Codable properties even if unread |
| `retain_swift_ui_previews` | Keep SwiftUI Preview providers |

---

## Common Scenarios

### Unused Protocol Method

When Periphery reports an unused protocol method:

1. **Search first:** `grep -r "methodName" Libraries/**/Tests/`
2. Remove from protocol definition
3. Remove from all conforming types (including mocks!)
4. Delete test cases that test this method
5. Update any mock that implements this protocol

### Unused MemoryDataSource Methods

Cache/storage methods might be unused if caching isn't implemented yet. Options:

1. **Remove**: If not planned for near future
   - Also remove from `{Name}MemoryDataSourceMock`
   - Delete tests in `{Name}MemoryDataSourceTests.swift`
2. **Keep**: Add to `report_exclude` if intentionally reserved

### Unused ViewState Equatable

Custom `==` implementations on ViewState enums may be reported as unused because SwiftUI doesn't require `Equatable` for view state. However, tests use these implementations for assertions like `#expect(sut.state == .loaded(expected))`.

**When removing `==` from ViewState:**

1. Remove the `==` function from production code
2. Create an Equatable extension in `Tests/Extensions/`:

```swift
// Tests/Extensions/MyViewState+Equatable.swift
@testable import MyModule

extension MyViewState: @retroactive Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading):
			true
		case let (.loaded(lhsValue), .loaded(rhsValue)):
			lhsValue == rhsValue
		case let (.error(lhsError), .error(rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}
```

**Note:** Use `@retroactive` to silence the "conformance of imported type" warning.

See `/testing` skill for more details on Equatable extensions.

### Unused Model Properties

If a Domain Model property is unused:

1. Check if it's mapped from DTO (might be needed for API contract)
2. If truly unused, remove from model
3. Update all initializers and stubs
4. Remove from DTO mapping if applicable

---

## Checklist

- [ ] Periphery scan completed
- [ ] **Tests and mocks searched BEFORE removing code**
- [ ] All unused code removed from production
- [ ] Related mocks updated (removed methods)
- [ ] Related tests deleted or updated
- [ ] Equatable extensions created in Tests/Extensions/ if needed
- [ ] SwiftLint auto-fix executed
- [ ] All module tests pass (build + tests)
- [ ] Final Periphery scan shows no unused code
