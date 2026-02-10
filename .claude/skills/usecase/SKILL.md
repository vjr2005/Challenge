---
name: usecase
description: Creates UseCases that encapsulate business logic. Use when creating use cases, implementing domain rules, validations, or coordinating multiple repositories. For any repository-related needs (domain models, errors, contracts, mappers, repository implementations), delegate to the /repository skill.
---

# Skill: UseCase

Guide for creating UseCases following Clean Architecture.

## Workflow

### Step 1 — Identify UseCase Type

| Type | When | Reference |
|------|------|-----------|
| Get / Refresh | CRUD with cache policy | [references/get-refresh.md](references/get-refresh.md) |
| Search | Query-based, always remote | [references/search.md](references/search.md) |
| Business Logic | Filtering, validation, transformation | [references/business-logic.md](references/business-logic.md) |
| Multiple Repositories | Coordinates data from 2+ repos | [references/multiple-repositories.md](references/multiple-repositories.md) |

### Step 2 — Ensure Repository Exists

Before creating a UseCase, verify the required Repository exists in `Sources/Domain/Repositories/`.

- **Repository found?** → Go to Step 3
- **No Repository found?** → Invoke the `/repository` skill first. Return here after completion.

### Step 3 — Implement UseCase

Read the appropriate reference from Step 1 and implement. Each reference includes implementation, mock, and tests:

1. Contract + Implementation in `Sources/Domain/UseCases/`
2. Mock in `Tests/Shared/Mocks/`
3. Tests in `Tests/Unit/Domain/UseCases/`
4. Run tests

---

## Core Pattern

Each UseCase encapsulates **one business operation** with **exactly one method: `execute`**.

> **CRITICAL:** Never add multiple methods or cache policy parameters. Create separate UseCases instead:
> - `GetCharacterUseCase` (localFirst) + `RefreshCharacterUseCase` (remoteFirst)
> - `GetCharactersPageUseCase` (list) + `SearchCharactersPageUseCase` (search)

### Naming Convention

| Operation | UseCase Name | Cache Policy |
|-----------|--------------|--------------|
| Get single | `Get{Name}UseCase` | localFirst (implicit) |
| Refresh single | `Refresh{Name}UseCase` | remoteFirst (implicit) |
| Get list | `Get{Name}sPageUseCase` | localFirst (implicit) |
| Refresh list | `Refresh{Name}sPageUseCase` | remoteFirst (implicit) |
| Search | `Search{Name}sPageUseCase` | none (always remote) |
| Create / Update / Delete | `{Action}{Name}UseCase` | — |

### File Structure

```
Features/{Feature}/
├── Sources/Domain/UseCases/
│   └── Get{Name}UseCase.swift       # Contract + Implementation
└── Tests/
    ├── Unit/Domain/UseCases/
    │   └── Get{Name}UseCaseTests.swift
    └── Shared/Mocks/
        └── Get{Name}UseCaseMock.swift
```

### Contract

```swift
protocol Get{Name}UseCaseContract: Sendable {
    func execute(identifier: Int) async throws({Feature}Error) -> {Name}
}
```

Internal visibility, `Sendable`, typed throws, returns Domain models.

### Implementation

```swift
struct Get{Name}UseCase: Get{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        try await repository.get{Name}(identifier: identifier, cachePolicy: .localFirst)
    }
}
```

Internal visibility, inject Repository via protocol, business logic goes here (not in Repository).

### Mock

```swift
@testable import {AppName}{Feature}

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    @MainActor init() {}

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}
```

`Mock` suffix, `@unchecked Sendable`, `@MainActor init() {}`, default `.failure` result, call tracking, no cachePolicy tracking.

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Contract | internal | `Sources/Domain/UseCases/` |
| Implementation | internal | `Sources/Domain/UseCases/` |
| Mock | internal | `Tests/Shared/Mocks/` |
