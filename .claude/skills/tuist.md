# Tuist

Skill for managing Tuist configuration in the project.

## Adding an XCFramework as a Dependency

### 1. XCFramework Location

Place the `.xcframework` file in the `Tuist/Dependencies/` directory:

```
Challenge/
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
