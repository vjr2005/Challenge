# Prompt Phase 3 — Generate all Tuist helpers

## Input

1. `AUDIT_REPORT.md`
2. `Tuist.swift` and `Tuist/Package.swift` generated in the previous phase

## Reference project

Use the Tuist helpers from [Challenge](https://github.com/vjr2005/Challenge) (`Tuist/ProjectDescriptionHelpers/`) as the **primary reference** for structure and patterns. Do NOT copy its configurations, modules, or dependencies — adapt the patterns to the project being migrated using data from the audit report.

Additionally, [mastodon-ios-tuist](https://github.com/tuist/mastodon-ios-tuist) can be used as a **secondary reference** to cross-check how extensions, scripts, and advanced Tuist API features are declared.

## Task

Generate ALL files in `Tuist/ProjectDescriptionHelpers/` following the same structure and patterns from the reference project but adapted to the real app.

### Config.swift
- appName: real app name (from the report)
- destinations: supported platforms (from the report)
- developmentTarget: deployment target (from the report, IPHONEOS_DEPLOYMENT_TARGET field)
- projectBaseSettings: SettingsDictionary with the settings common to all targets ('Build Settings' section of the report, group a)

### BuildConfiguration.swift
- One CustomConfiguration per project configuration ('Schemes and Environments' section of the report)
- Configuration-specific settings ('Build Settings' section, group b)
- Static property `all: [CustomConfiguration]`

### Environment.swift
- Enum with one case per environment detected in the report
- For each environment: apiURL, bundleId, appIcon, displayName (exact values from the report, 'Schemes and Environments' section)
- Method to generate the environment-specific SettingsDictionary

### Module.swift
- Struct with stored properties: directory, name, hasMocks
- Computed properties: packageReference, targetDependency, mocksTargetDependency, codeCoverageTargetReference
- Factory method create(directory:) that derives the module name from the last path component, prefixed with the app name
- Automatically detect if the module has a Mocks/ folder

### Modules.swift
- One global constant per local SPM module in the project (use targets_by_dependency.txt and the Package.swift files for the complete list)
- Enum Modules with static let all: [Module]
- Computed: packageReferences, projectPaths, codeCoverageTargets

### App.swift
- App target:
  a) infoPlist: .extendingDefault(with:) using the non-default keys from the report ('Info.plist' section)
  b) sources: glob of the app directory
  c) resources: all resources from the report ('Resources and Assets' section)
  d) entitlements: path to the .entitlements
  e) dependencies: AppKit + direct app dependencies
  f) settings: signing config from the report ('Signing and Capabilities' section)
  g) scripts: all Run Script build phases from the report ('Build Phases' section), translated to TargetScript
- UI tests target:
  a) dependencies: mock server + any test dependencies
  b) launchArguments and environmentVariables from the report
- project property that combines them

### AppScheme.swift
- Factory that generates a Scheme per environment from the Environment enum
- Each scheme: buildAction, runAction (with corresponding config), testAction (with test targets), archiveAction
- Additional scheme for UI tests (launch arguments, environment variables from the report)
- Additional scheme for module tests (test plan if one exists)
- Code coverage enabled with codeCoverageTargets from Modules

### BuildScripts.swift
- Helper that centralizes ALL Run Script build phases from the project as static methods returning TargetScript
- For each Run Script detected in the audit ('Build Phases' section), create a method: swiftLint(), crashlytics(), codeGeneration(), etc.
- Example (SwiftLint): invocation via mise, basedOnDependencyAnalysis: false
- Each script must include the input/output files if they existed in the original project
- App.swift targets reference these methods in their `scripts` array

## Rules
- Follow the same structure and patterns from the reference project
- Use the EXACT values from the audit report
- All files must have `import ProjectDescription`
- Public properties and types so they are accessible from Project.swift and Workspace.swift
- Do not include Workspace.swift or Project.swift helpers here (they are generated in phase 4)

## Format
Generate each file completely, ready to copy. Separate each file with a heading: `// === Tuist/ProjectDescriptionHelpers/FileName.swift ===`
