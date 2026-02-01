# Tuist Configuration

The project uses **Tuist** for project generation with helpers in `Tuist/ProjectDescriptionHelpers/`:

| File | Purpose |
|------|---------|
| `Config.swift` | Global configuration (app name, Swift version, deployment target) |
| `Modules.swift` | Module registry and dependencies |
| `FrameworkModule.swift` | Module definition helper |
| `BuildConfiguration.swift` | Debug/Release configurations |
| `Environment.swift` | Environment-specific settings |
| `AppScheme.swift` | Xcode scheme generation |
| `SwiftLint.swift` | SwiftLint build phase integration |

## Key Settings

```swift
// Config.swift
appName = "Challenge"
swiftVersion = "6.0"
developmentTarget = .iOS("17.0")
destinations = [.iPhone, .iPad]
```

## Swift 6 Concurrency

The project uses strict Swift 6 concurrency with:

```swift
"SWIFT_APPROACHABLE_CONCURRENCY": "YES"
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
```
