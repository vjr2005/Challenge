# ChallengeResources

Shared resources module providing localization utilities.

## Overview

ChallengeResources centralizes localization across the application, providing the `localized()` extension for type-safe string access.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Supported Languages

| Language | Code | Status |
|----------|------|--------|
| English | `en` | Source language |
| Spanish | `es` | Fully translated |

The app uses `.xcstrings` format (Apple's modern localization format for iOS 16+).

## Structure

```
Resources/
├── Package.swift
└── Sources/
    ├── Extensions/
    │   └── String+Localized.swift
    └── Resources/
        └── Localizable.xcstrings
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeResources` | SPM Library | Localization utilities |

## Components

### String+Localized

Extension for accessing localized strings:

```swift
public extension String {
    func localized() -> String
    func localized(_ arguments: CVarArg...) -> String
}
```

### Bundle.module

SPM automatically generates `Bundle.module` for targets with resources. No manual accessor needed.

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

## Adding a New Language

1. Open `Localizable.xcstrings` in Xcode
2. Click the "+" button to add a new language
3. Translate all strings to the new language
4. Update `CFBundleLocalizations` in `Project.swift`:
   ```swift
   "CFBundleLocalizations": ["en", "es", "NEW_LANG_CODE"],
   ```
5. Regenerate the project: `./generate.sh`

## Project Configuration

The main app must declare supported languages in `Project.swift` via `CFBundleLocalizations`:

```swift
let appInfoPlist: [String: Plist.Value] = [
    "CFBundleLocalizations": ["en", "es"],
    // ...
]
```

> **Important:** iOS does not load localizations from embedded frameworks unless the main app declares supported languages in `CFBundleLocalizations`. Without this, the app will always show the development language (English) regardless of device settings.

## Key Naming

| Pattern | Example |
|---------|---------|
| `{screen}.{element}` | `home.title` |
| `{screen}.{section}.{element}` | `characterList.empty.title` |
| `common.{element}` | `common.tryAgain` |

## Testing

```bash
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -testPlan Challenge \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```
