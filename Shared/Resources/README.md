# ChallengeResources

Shared resources module providing localization utilities.

## Overview

ChallengeResources centralizes localization across the application, providing the `localized()` extension for type-safe string access.

## Structure

```
Resources/
├── Sources/
│   ├── Extensions/
│   │   ├── Bundle+Module.swift
│   │   └── String+Localized.swift
│   └── Resources/
│       └── Localizable.xcstrings
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeResources` | Framework | Localization utilities |

## Components

### String+Localized

Extension for accessing localized strings:

```swift
public extension String {
    func localized() -> String
    func localized(_ arguments: CVarArg...) -> String
}
```

### Bundle+Module

Manual bundle accessor (Tuist's generated accessors are disabled):

```swift
extension Bundle {
    static let module: Bundle
}
```

## Usage

```swift
import ChallengeResources

// Simple localization
let title = "home.title".localized()

// With format arguments
let count = "home.itemCount %lld".localized(5)
```

### In Views

Each View defines a private `LocalizedStrings` enum:

```swift
private enum LocalizedStrings {
    static var title: String { "myView.title".localized() }
    static func itemCount(_ count: Int) -> String {
        "myView.itemCount %lld".localized(count)
    }
}
```

## Adding Strings

1. Add key to `Localizable.xcstrings`
2. Provide translations for all languages (en, es)
3. Add to View's `LocalizedStrings` enum

## Key Naming

| Pattern | Example |
|---------|---------|
| `{screen}.{element}` | `home.title` |
| `{screen}.{section}.{element}` | `characterList.empty.title` |
| `common.{element}` | `common.tryAgain` |

## Testing

```bash
tuist test ChallengeResources
```
