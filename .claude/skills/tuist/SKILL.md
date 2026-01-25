---
name: tuist
description: Manages Tuist configuration. Use when adding xcframeworks, configuring dependencies, or modifying Project.swift.
---

# Tuist

Skill for managing Tuist configuration in the project.

## MCP Server (Required)

**IMPORTANT:** This project has a Tuist MCP server installed. Always use the MCP tools for Tuist operations instead of running bash commands directly.

### Available MCP Resources

The Tuist MCP server provides project graph information:

```
URI: tuist:///{project-path}
Resource: {AppName} graph
Type: application/json
```

Use `ReadMcpResourceTool` to read the project graph and understand:
- Project structure and targets
- Dependencies between modules
- Build configurations

### Usage

```swift
// Read project graph
ReadMcpResourceTool(
    server: "tuist",
    uri: "tuist:///{project-path}"
)
```

### Why use MCP?

- Provides structured JSON output of project configuration
- Enables understanding of module dependencies
- Integrates directly with Claude Code workflow

> **Note:** Use `ListMcpResourcesTool` to see all available Tuist resources.

---

## Project Options

The project disables Tuist's code generation to keep full control over the codebase:

```swift
// Project.swift
let project = Project(
    name: appName,
    options: .options(
        automaticSchemesOptions: .disabled,
        developmentRegion: "en",
        disableBundleAccessors: true,              // No TuistBundle+*.swift
        disableSynthesizedResourceAccessors: true  // No TuistAssets+*.swift
    ),
    ...
)
```

### Why disable synthesizers?

| Option | Effect | Reason |
|--------|--------|--------|
| `disableBundleAccessors` | No `TuistBundle+*.swift` | Manual `Bundle+Module.swift` in modules |
| `disableSynthesizedResourceAccessors` | No `TuistAssets+*.swift` | Not using generated asset accessors |

### Manual Bundle.module

Modules that need `Bundle.module` (for resources like `Localizable.xcstrings`) must include:

```swift
// Sources/Bundle+Module.swift
import Foundation

private final class BundleFinder {}

extension Bundle {
    static let module = Bundle(for: BundleFinder.self)
}
```

Currently used in:
- `Shared/Resources/Sources/Extensions/Bundle+Module.swift`
- `Features/{Feature}/Tests/Extensions/Bundle+Module.swift`

---

## URL Schemes (Deep Links)

To enable the app to receive external URLs (from Safari, other apps, push notifications), configure `CFBundleURLTypes` in the app's Info.plist:

```swift
// Project.swift
let appInfoPlist: [String: Plist.Value] = [
    "UILaunchStoryboardName": "LaunchScreen",
    // ... other settings ...
    "CFBundleURLTypes": [
        [
            "CFBundleURLSchemes": ["challenge"],
            "CFBundleURLName": "com.app.Challenge",
        ],
    ],
]
```

**Configuration:**

| Key | Value | Description |
|-----|-------|-------------|
| `CFBundleURLSchemes` | `["challenge"]` | URL scheme the app responds to |
| `CFBundleURLName` | `"com.app.Challenge"` | Unique identifier for this URL type |

**Usage:**

After configuration, the app can receive URLs like:
- `challenge://character/list`
- `challenge://character/detail?id=42`

Handle incoming URLs in `RootView` with `.onOpenURL`:

```swift
.onOpenURL { url in
    router.navigate(to: url)
}
```

See `/router` skill for deep link implementation details.

---

## Derived Folder

Tuist generates files in the `Derived/` folder:

```
Derived/
└── InfoPlists/
    ├── {AppName}-Info.plist
    ├── {AppName}Core-Info.plist
    ├── {AppName}Resources-Info.plist
    └── ...
```

**Contents:** Only `Info.plist` files for each target (no generated Swift code).

**Git:** The `Derived/` folder is in `.gitignore`.

---

## Adding an XCFramework as a Dependency

### 1. XCFramework Location

Place the `.xcframework` file in the `Tuist/Dependencies/` directory:

```
{AppName}/
├── Tuist/
│   ├── Dependencies/
│   │   └── FrameworkName.xcframework
│   └── ProjectDescriptionHelpers/
├── Libraries/
├── App/
└── Project.swift
```

> **Note:** The `Tuist/Dependencies/` directory is ignored by git. Do not commit xcframeworks to the repository.

### 2. Create the XCFrameworks Helper

If it doesn't exist, create the file `Tuist/ProjectDescriptionHelpers/Dependencies.swift`:

```swift
import ProjectDescription

public enum XCFrameworks {
  public static let frameworkName: TargetDependency = .xcframework(path: "Tuist/Dependencies/FrameworkName.xcframework")
}
```

### 3. Add the Dependency to a Target

In `Project.swift`, add the dependency to the target that needs it:

```swift
.target(
  name: appName,
  destinations: [.iPhone, .iPad],
  product: .app,
  bundleId: "com.app.\(appName)",
  deploymentTargets: developmentTarget,
  sources: ["App/Sources/**"],
  resources: ["App/Sources/Resources/**"],
  dependencies: [
    XCFrameworks.frameworkName,
  ]
)
```

### 4. For Internal Frameworks

If the xcframework is a dependency of an internal framework in `Libraries/`, update `Target+Framework.swift`:

```swift
public extension Target {
  static func createFramework(
    name: String,
    destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
    dependencies: [TargetDependency] = []
  ) -> Self {
    let targetName = "\(appName)\(name)"
    return .target(
      name: targetName,
      destinations: destinations,
      product: .framework,
      bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
      sources: ["Libraries/\(name)/**"],
      dependencies: dependencies
    )
  }
}
```

Then in `Project.swift`:

```swift
.createFramework(
  name: "Features/UserFeature",
  dependencies: [
    XCFrameworks.frameworkName,
  ]
)
```

### 5. Regenerate the Project

```bash
tuist generate
```
