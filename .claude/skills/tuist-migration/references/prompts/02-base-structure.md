# Prompt Phase 2 — Generate complete base structure

## Input

`AUDIT_REPORT.md`

## Reference project

Use the Tuist configuration from [Challenge](https://github.com/vjr2005/Challenge) as the **primary reference** for Tuist API syntax and helper patterns (`Tuist.swift`, `Tuist/Package.swift`). Do NOT copy its configurations, bundle IDs, or dependencies — adapt the patterns to the project being migrated.

Additionally, [mastodon-ios-tuist](https://github.com/tuist/mastodon-ios-tuist) can be used as a **secondary reference** to cross-check Tuist API usage or resolve doubts about advanced configurations.

## Task

Generate the 3 base files for the Tuist structure:

### 1. Tuist.swift
- fullHandle with the organization and app name
- compatibleXcodeVersions for the team's current version
- swiftVersion according to the SWIFT_VERSION from the audit report

### 2. Tuist/Package.swift
- `#if TUIST` block with PackageSettings:
  a) productTypes: for each external dependency from the report, indicate .framework (dynamic, for cache) or .staticFramework
  b) baseSettings: with the build configurations from the report
  c) targetSettings: one entry per local SPM module. Use the data from the 'SPM ↔ Xcode Coherence' section of the report to determine which settings each target needs. Modules with SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated need a specific SettingsDictionary
- `let package` block with all remote external dependencies from the report (exact URLs and versions)

### 3. .gitignore
- Add the necessary entries for Tuist: *.xcodeproj, *.xcworkspace, Derived/, .build/, .swiftpm/, Package.resolved, .package.resolved
- Preserve existing entries from the current .gitignore

## Rules
- Use the EXACT values from the audit report, do not invent them
- The project name must carry the -Tuist suffix during migration
- Include comments explaining each section
- The code must compile with ProjectDescription from Tuist 4.x

## Format
Generate each file completely, ready to copy. Separate each file with a heading indicating its relative path.
