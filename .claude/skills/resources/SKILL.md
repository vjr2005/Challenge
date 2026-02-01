---
name: resources
description: Resources module: localization, String extensions. Use when working with localized strings or shared resources.
---

# Skill: Resources

Guide for the Resources module: localization and shared resources.

## When to use this skill

- Work with localized strings
- Add new translations
- Understand the localization system

---

## Module Overview

The `Resources` module provides app-specific resources used across features:

- **Localization**: Centralized strings with `String.localized()` extension
- **Bundle**: Manual `Bundle.module` accessor for resources

**Location:** `Shared/Resources/`

**Note:** Shared modules are app-specific (not reusable across apps), unlike Libraries which are generic and reusable.

**Structure:**
```
Shared/Resources/
├── Sources/
│   ├── Extensions/
│   │   ├── Bundle+Module.swift       # Bundle.module accessor
│   │   └── String+Localized.swift    # localized() extension
│   └── Resources/
│       └── Localizable.xcstrings
└── Tests/
```

---

## Localization

All localized strings are centralized in the Resources module.

**Location:** `Shared/Resources/Sources/Resources/Localizable.xcstrings`

### String Extension

The `localized()` extension converts string keys to localized values:

```swift
// Shared/Resources/Sources/Extensions/String+Localized.swift
public extension String {
    func localized() -> String {
        String(localized: LocalizationValue(self), bundle: .module)
    }

    func localized(_ arguments: CVarArg...) -> String {
        let localizedFormat = String(localized: LocalizationValue(self), bundle: .module)
        return String(format: localizedFormat, arguments: arguments)
    }
}
```

### Expected Xcode Warnings

When building, Xcode may show these warnings:

```
Skipping extraction of localizable string with non-literal key
```

**These warnings are expected and safe to ignore.** They occur because Xcode's automatic string extraction cannot analyze dynamic keys like `LocalizationValue(self)`. The localization system works correctly—these warnings only indicate that Xcode won't auto-extract keys from `localized()` calls.

**Why this pattern?** It allows type-safe, reusable localization without repeating bundle references. Translations are managed manually in `.xcstrings` files.

---

### Usage in Views

Each View defines a private `LocalizedStrings` enum that uses `localized()`:

```swift
import {AppName}Resources

struct MyView: View {
    var body: some View {
        Text(LocalizedStrings.title)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "myView.title".localized() }
    static var subtitle: String { "myView.subtitle".localized() }
    static func itemCount(_ count: Int) -> String {
        "myView.itemCount %lld".localized(count)
    }
}
```

### Adding New Strings

1. Add the key to `Shared/Resources/Sources/Resources/Localizable.xcstrings`
2. Provide translations for all supported languages (en, es)
3. Add the string to the View's private `LocalizedStrings` enum

### String Key Naming Convention

| Pattern | Example |
|---------|---------|
| `{screen}.{element}` | `home.title` |
| `{screen}.{section}.{element}` | `characterList.empty.title` |
| `common.{element}` | `common.tryAgain` |

---

## Bundle.module

The `Bundle+Module.swift` file provides access to the module's resource bundle.

**Why manual?** Tuist's bundle accessor generation is disabled (`disableBundleAccessors: true`) to avoid generated code.

```swift
// Shared/Resources/Sources/Extensions/Bundle+Module.swift
import Foundation

private final class BundleFinder {}

extension Bundle {
    static let module = Bundle(for: BundleFinder.self)
}
```

**Used by:** `String.localized()` to access `Localizable.xcstrings`.

**Note:** Any module needing `Bundle.module` must include its own `Bundle+Module.swift`.

---

## Checklist

### Adding Localized Strings

- [ ] Add key to `Localizable.xcstrings` with all translations
- [ ] Add to View's private `LocalizedStrings` enum
- [ ] Use `localized()` or `localized(_:)` for interpolation
