---
name: app-configuration
autoContext: true
description: Environment and build configuration. Use when working with environments, schemes, build configs, or API configuration.
---

# Skill: App Configuration

Guide for environment and build configuration management.

## When to use this skill

- Configure different environments (dev, staging, prod)
- Add new API configurations
- Understand build configurations and schemes
- Work with app icons per environment

---

## Environment

The `Environment` enum defines application environments and provides API configuration.

**Location:** `Libraries/AppConfiguration/Sources/Environment.swift`

### Usage

```swift
import ChallengeAppConfiguration

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
| Development | AppIconDev | 🟠 Orange "DEV" |
| Staging | AppIconStaging | 🟣 Purple "STAGING" |
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
import ChallengeAppConfiguration
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
import ChallengeAppConfiguration

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
