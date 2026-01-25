---
name: common
description: Shared module: AppEnvironment, localization, String extensions. Use when working with environments, schemes, build configs, API configuration, or localized strings.
---

# Skill: Shared

Guide for the Shared module: environment configuration and localization.

## When to use this skill

- Configure different environments (dev, staging, prod)
- Add new API configurations
- Understand build configurations and schemes
- Work with app icons per environment
- Work with localized strings

---

## Module Overview

The `Shared` module provides app-specific utilities used across features:

- **Localization**: Centralized strings with `String.localized()` extension
- **Bundle**: Manual `Bundle.module` accessor for resources

**Location:** `Shared/Common/`

**Note:** Shared modules are app-specific (not reusable across apps), unlike Libraries which are generic and reusable.

**Structure:**
```
Shared/Common/
├── Sources/
│   ├── Extensions/
│   │   ├── Bundle+Module.swift       # Bundle.module accessor
│   │   └── String+Localized.swift    # localized() extension
│   └── Resources/
│       └── Localizable.xcstrings
└── Tests/
```

**Note:** The base `AppEnvironment` enum is defined in `Core` module (`Libraries/Core/Sources/AppEnvironment/AppEnvironment.swift`). API configuration extensions are in `App/Sources/Data/AppEnvironment+API.swift`.

---

## AppEnvironment

The `AppEnvironment` enum defines application environments. The base definition is in Core, and the App extends it with API configuration.

**Base definition:** `Libraries/Core/Sources/AppEnvironment/AppEnvironment.swift`
**API extension:** `App/Sources/Data/AppEnvironment+API.swift`

### Usage

```swift
import {AppName}Core

// Get current environment (determined at compile time)
let environment = AppEnvironment.current

// Check environment type
if environment.isDebug {
    // Development-only code
}

// Get API configuration (within App target)
let apiURL = AppEnvironment.current.rickAndMorty.baseURL
```

### Environment Cases

| Case | Description |
|------|-------------|
| `development` | Local development with debug tools |
| `staging` | Pre-production testing environment |
| `production` | Live production environment |

### Properties (from Core)

| Property | Type | Description |
|----------|------|-------------|
| `current` | `AppEnvironment` | Current environment based on build configuration |
| `isDebug` | `Bool` | `true` only for `development` |
| `isRelease` | `Bool` | `true` only for `production` |

### Properties (from App)

| Property | Type | Description |
|----------|------|-------------|
| `rickAndMorty` | `API` | API configuration with `baseURL` |

---

## Localization

All localized strings are centralized in the Common module.

**Location:** `Shared/Common/Sources/Resources/Localizable.xcstrings`

### String Extension

The `localized()` extension converts string keys to localized values:

```swift
// Shared/Common/Sources/Extensions/String+Localized.swift
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
import {AppName}Shared

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

1. Add the key to `Shared/Common/Sources/Resources/Localizable.xcstrings`
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
// Shared/Common/Sources/Extensions/Bundle+Module.swift
import Foundation

private final class BundleFinder {}

extension Bundle {
    static let module = Bundle(for: BundleFinder.self)
}
```

**Used by:** `String.localized()` to access `Localizable.xcstrings`.

**Note:** Any module needing `Bundle.module` must include its own `Bundle+Module.swift`.

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
| `{AppName} (Dev)` | Debug | Release | Daily development |
| `{AppName} (Staging)` | Debug-Staging | Staging | Testing with staging API |
| `{AppName} (Prod)` | Debug-Prod | Release | Debugging production issues |

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
// In App/Sources/Data/AppEnvironment+API.swift
extension AppEnvironment {
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

## Usage in App

The App accesses API configuration through `AppContainer`:

```swift
import {AppName}Core
import {AppName}Networking

struct AppContainer: Sendable {
    let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )
    }
}
```

**Note:** API configuration is internal to the App target. Features receive the configured `HTTPClient` via dependency injection.

---

## Environment Detection

The current environment is determined at compile time using Swift compiler flags:

```swift
// In Core module
public enum AppEnvironment {
    case development
    case staging
    case production

    public static var current: AppEnvironment {
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
import {AppName}Shared

// Logging only in debug
if AppEnvironment.current.isDebug {
    print("Debug: \(message)")
}

// Feature flags by environment
var isFeatureEnabled: Bool {
    switch AppEnvironment.current {
    case .development, .staging:
        return true
    case .production:
        return false
    }
}

// Analytics
func track(event: String) {
    guard AppEnvironment.current.isRelease else { return }
    analytics.track(event)
}
```

---

## Checklist

### Adding New Environment

- [ ] Add case to `AppEnvironment` enum in Core
- [ ] Update `current` property with compiler flag logic
- [ ] Add build configuration in Xcode/Tuist
- [ ] Add scheme for the environment
- [ ] Create app icon variant if needed
- [ ] Update API configurations in Shared

### Adding New API

- [ ] Add computed property to `AppEnvironment` extension in `App/Sources/Data/AppEnvironment+API.swift`
- [ ] Define URL for each environment case
- [ ] Use `preconditionFailure` for invalid URLs (compile-time constants)
- [ ] Update `AppContainer` to use new API
- [ ] Add tests in `App/Tests/Data/`

### Adding Localized Strings

- [ ] Add key to `Localizable.xcstrings` with all translations
- [ ] Add to View's private `LocalizedStrings` enum
- [ ] Use `localized()` or `localized(_:)` for interpolation
