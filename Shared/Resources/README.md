# ChallengeResources

Shared resources module providing localization and bundle utilities.

## Overview

ChallengeResources centralizes resource management across the application, providing utilities for accessing localized strings and module bundles.

## Structure

```
Resources/
└── Sources/
    └── Extensions/
        ├── Bundle+Module.swift      # Module bundle access
        └── String+Localized.swift   # Localization helpers
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeResources` | Framework | Resource utilities |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Base infrastructure |

## Components

### Bundle+Module

Extension providing access to the module's bundle for loading resources:

```swift
extension Bundle {
    /// Returns the bundle for the ChallengeResources module
    static var module: Bundle { ... }
}
```

### String+Localized

Extension for easy access to localized strings:

```swift
extension String {
    /// Returns a localized version of the string
    var localized: String { ... }

    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg...) -> String { ... }
}
```

## Usage

### Accessing Localized Strings

```swift
// Simple localization
let title = "welcome_title".localized

// With format arguments
let greeting = "hello_user".localized(with: userName)
```

### Accessing Module Bundle

```swift
// Load an image from the resources bundle
let image = UIImage(named: "icon", in: .module, compatibleWith: nil)

// Load a file from the resources bundle
let url = Bundle.module.url(forResource: "data", withExtension: "json")
```

## Localization Files

Localized strings should be added to `.strings` files in the Resources module:

```
Resources/
└── Sources/
    └── Resources/
        ├── en.lproj/
        │   └── Localizable.strings
        └── es.lproj/
            └── Localizable.strings
```

## Best Practices

1. **Centralize strings**: All user-facing strings should be defined in this module
2. **Use semantic keys**: Name keys by purpose, not content (e.g., `character_list_title` not `characters`)
3. **Document placeholders**: Comment format strings with placeholder descriptions
4. **Test localization**: Verify strings render correctly in all supported languages
