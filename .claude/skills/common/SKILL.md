---
name: common
description: Common module: Environment, localization, String extensions. Use when working with environments, schemes, build configs, API configuration, or localized strings.
---

# Skill: Common

Guide for the Common module: environment configuration and localization.

## When to use this skill

- Configure different environments (dev, staging, prod)
- Add new API configurations
- Understand build configurations and schemes
- Work with app icons per environment
- Work with localized strings

---

## Module Overview

The `Common` module provides shared utilities used across features:

- **Environment**: Build configuration and API endpoints
- **Localization**: Centralized strings with `String.localized()` extension

**Location:** `Libraries/Common/`

---

## Environment

The `Environment` enum defines application environments and provides API configuration.

**Location:** `Libraries/Common/Sources/Environment.swift`

### Usage

```swift
import ChallengeCommon

// Get current environment (determined at compile time)
let environment = Environment.current

// Check environment type
if environment.isDebug {
    // Development-only code
}

// Get API configuration
let apiURL = Environment.current.rickAndMorty.baseURL
```

### Environment Cases

| Case | Description |
|------|-------------|
| `development` | Local development with debug tools |
| `staging` | Pre-production testing environment |
| `production` | Live production environment |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `current` | `Environment` | Current environment based on build configuration |
| `isDebug` | `Bool` | `true` only for `development` |
| `isRelease` | `Bool` | `true` only for `production` |
| `rickAndMorty` | `API` | API configuration with `baseURL` |

---

## Localization

All localized strings are centralized in the Common module.

**Location:** `Libraries/Common/Sources/Resources/Localizable.xcstrings`

### String Extension

The `localized()` extension converts string keys to localized values:

```swift
// Libraries/Common/Sources/String+Localized.swift
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

### Usage in Views

Each View defines a private `LocalizedStrings` enum that uses `localized()`:

```swift
import ChallengeCommon

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

1. Add the key to `Libraries/Common/Sources/Resources/Localizable.xcstrings`
2. Provide translations for all supported languages (en, es)
3. Add the string to the View's private `LocalizedStrings` enum

### String Key Naming Convention

| Pattern | Example |
|---------|---------|
| `{screen}.{element}` | `home.title` |
| `{screen}.{section}.{element}` | `characterList.empty.title` |
| `common.{element}` | `common.tryAgain` |

---

## Build Configurations

| Configuration | Type | Bundle ID | App Icon | Environment |
|---------------|------|-----------|----------|-------------|
| Debug | debug | `.dev` | AppIconDev | development |
| Debug-Staging | debug | `.staging` | AppIconStaging | staging |
| Debug-Prod | debug | (none) | AppIcon | production |
| Staging | release | `.staging` | AppIconStaging | staging |
| Release | release | (none) | AppIcon | production |

**Debug configurations** enable debugging and development tools.
**Release configurations** are optimized builds for distribution.

---

## Schemes

| Scheme | Run Config | Archive Config | Use Case |
|--------|------------|----------------|----------|
| `Challenge (Dev)` | Debug | Release | Daily development |
| `Challenge (Staging)` | Debug-Staging | Staging | Testing with staging API |
| `Challenge (Prod)` | Debug-Prod | Release | Debugging production issues |

**Run Config**: Configuration used when running in simulator/device (debuggable).
**Archive Config**: Configuration used when creating archives for distribution.

---

## App Icons

Each environment has a distinct app icon with a colored banner:

| Environment | Icon | Banner |
|-------------|------|--------|
| Development | AppIconDev | Orange "DEV" |
| Staging | AppIconStaging | Purple "STAGING" |
| Production | AppIcon | No banner |

**Location:** `App/Sources/Resources/Assets.xcassets/`

---

## Adding a New API

To add a new API endpoint configuration:

```swift
// In Environment.swift
public extension Environment {
    var newAPI: API {
        let urlString: String
        switch self {
        case .development:
            urlString = "https://dev.api.example.com"
        case .staging:
            urlString = "https://staging.api.example.com"
        case .production:
            urlString = "https://api.example.com"
        }
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL: \(urlString)")
        }
        return API(baseURL: url)
    }
}
```

---

## Usage in Features

Features access API configuration through their Container:

```swift
import ChallengeCommon
import ChallengeNetworking

final class MyFeatureContainer {
    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: Environment.current.rickAndMorty.baseURL
        )
    }
}
```

---

## Environment Detection

The current environment is determined at compile time using Swift compiler flags:

```swift
public enum Environment {
    case development
    case staging
    case production

    public static var current: Environment {
        #if DEBUG
            #if STAGING
                return .staging
            #elseif PRODUCTION
                return .production
            #else
                return .development
            #endif
        #else
            #if STAGING
                return .staging
            #else
                return .production
            #endif
        #endif
    }
}
```

---

## Compiler Flags by Configuration

| Configuration | Flags |
|---------------|-------|
| Debug | `DEBUG` |
| Debug-Staging | `DEBUG`, `STAGING` |
| Debug-Prod | `DEBUG`, `PRODUCTION` |
| Staging | `STAGING` |
| Release | (none) |

---

## API Struct

```swift
public struct API {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
```

---

## Environment-Specific Behavior

```swift
import ChallengeCommon

// Logging only in debug
if Environment.current.isDebug {
    print("Debug: \(message)")
}

// Feature flags by environment
var isFeatureEnabled: Bool {
    switch Environment.current {
    case .development, .staging:
        return true
    case .production:
        return false
    }
}

// Analytics
func track(event: String) {
    guard Environment.current.isRelease else { return }
    analytics.track(event)
}
```

---

## Checklist

### Adding New Environment

- [ ] Add case to `Environment` enum
- [ ] Update `current` property with compiler flag logic
- [ ] Add build configuration in Xcode/Tuist
- [ ] Add scheme for the environment
- [ ] Create app icon variant if needed
- [ ] Update API configurations

### Adding New API

- [ ] Add computed property to `Environment` extension
- [ ] Define URL for each environment case
- [ ] Use `preconditionFailure` for invalid URLs (compile-time constants)
- [ ] Update feature Containers to use new API

### Adding Localized Strings

- [ ] Add key to `Localizable.xcstrings` with all translations
- [ ] Add to View's private `LocalizedStrings` enum
- [ ] Use `localized()` or `localized(_:)` for interpolation
