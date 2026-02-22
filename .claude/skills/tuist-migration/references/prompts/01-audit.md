# Prompt Phase 1 — Audit and migration report generation

## Prerequisite

Run `scripts/audit.sh`. The script generates `/tmp/tuist-audit/` with all project data.

## Reference project

Use the Tuist configuration from [Challenge](https://github.com/vjr2005/Challenge) as the **primary reference** for Tuist API syntax and helper patterns (`Tuist/ProjectDescriptionHelpers/`, `Project.swift`, `Workspace.swift`, `Tuist.swift`, `Tuist/Package.swift`). Do NOT copy its configurations, bundle IDs, modules, or dependencies — adapt the patterns to the project being migrated.

Additionally, [mastodon-ios-tuist](https://github.com/tuist/mastodon-ios-tuist) can be used as a **secondary reference** to cross-check Tuist API usage or resolve doubts about advanced configurations.

## Task

Analyze ALL files in `/tmp/tuist-audit/` and generate a complete audit report with the following sections:

### 1. Build Settings
- List all functional settings (not paths/UUIDs) grouped by:
  a) Common to all targets and configurations → will go into `Config.swift`
  b) Configuration-specific (Debug vs Release vs others) → will go into `BuildConfiguration.swift`
  c) Target-specific → will go into `targetSettings` in `Tuist/Package.swift`
- For each setting, indicate: name, value per configuration, and destination Tuist file
- Flag any setting that appears in check_empty_settings.txt (orphaned settings that could be lost)

### 2. SPM ↔ Xcode Coherence
- For each Package.swift, compare its swiftSettings with the resolved build settings of the corresponding target. Identify:
  a) Coherent settings (SPM swiftSettings reflected in Xcode)
  b) Discrepancies (settings that do not match)
  c) Settings in Xcode that are not in Package.swift (manual overrides)
  d) Settings in Package.swift that Xcode is not applying
- Pay special attention to modules with non-standard configuration (e.g., modules with SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated)

### 3. Info.plist
- List all Info.plist keys that are NOT in Xcode's default
- Group by category: localization, orientations, App Transport Security, URL schemes, background modes, capabilities, and custom keys
- For each key indicate its value and whether it is critical (its absence causes a crash or App Store rejection)

### 4. Signing and Capabilities
- Extract: DEVELOPMENT_TEAM, CODE_SIGN_IDENTITY, CODE_SIGN_STYLE, PROVISIONING_PROFILE_SPECIFIER (per configuration if they differ)
- List all capabilities from the .entitlements
- Indicate if there are app extensions that need their own signing config

### 5. Build Phases
- List all Run Script build phases with their content
- For each one indicate: name, execution order, input/output files, and how to translate it to Tuist (TargetScript)

### 6. Schemes and Environments
- List all workspace schemes
- For each scheme: build configuration, associated test targets, launch arguments, environment variables
- Identify the environments (Dev/Staging/Prod/others) and their differences: API URL, bundle ID, app icon, display name

### 7. Resources and Assets
- From file_tree.txt, list all resources that must be included: .xcassets, .lottie, .strings, .xcstrings, .storyboard, .xib, JSON fixtures
- Indicate which target each resource should be included in

### 8. External Dependencies
- List all remote SPM dependencies (URL + version)
- For each one indicate: which targets consume it, recommended type for Tuist (dynamic vs static framework), whether it is a cache candidate

### 9. Summary Table: Tuist file → required data
Generate a table with columns:
| Tuist File | Data from current project | Concrete values | Risk if omitted |
For these files: Config.swift, BuildConfiguration.swift, Environment.swift, App.swift, AppScheme.swift, Module.swift, Modules.swift, Tuist/Package.swift, BuildScripts.swift

### 10. Detected Risks
- List any anomaly, inconsistency, or unusual configuration that could complicate the migration
- Prioritize: CRITICAL (blocking), HIGH (functionality affected), MEDIUM (cosmetic)

## Output Format

Generate the report in Markdown. Use tables for structured data. The concrete setting values must be copy-pasteable for direct use in Tuist helpers. Save as `AUDIT_REPORT.md` at the project root.
