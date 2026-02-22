# Prompt Phase 4 — Generate Project.swift, Workspace.swift, and generate.sh

## Input

All helpers generated in phase 3, `Tuist.swift`, `Tuist/Package.swift`, and `AUDIT_REPORT.md`.

## Reference project

Use `Project.swift`, `Workspace.swift`, and `generate.sh` from [Challenge](https://github.com/vjr2005/Challenge) as the **primary reference** for structure and patterns.

Additionally, [mastodon-ios-tuist](https://github.com/tuist/mastodon-ios-tuist) can be used as a **secondary reference** to cross-check Tuist API usage or resolve doubts.

## Post-action

After applying the generated files: run `chmod +x scripts/generate.sh && scripts/generate.sh` to verify that `tuist generate` produces a functional project.

## Task

### 1. Project.swift (project root)
- Use App.project from the App.swift helper
- Must be minimal: `let project = App.project`

### 2. Workspace.swift (project root)
- Include the root project + all module projects (Modules.projectPaths)
- Workspace-level schemes: AppScheme.allSchemes() + UI tests + module tests
- Code coverage: configure codeCoverageTargets with the targets from Modules
- Workspace name: app name (with -Tuist suffix during migration)

### 3. generate.sh
A zsh script that:
- Accepts a --clean flag to clear Tuist cache and DerivedData
- Runs `mise x -- tuist install` to resolve dependencies
- Removes previous .xcodeproj files (except those in Tuist/)
- Runs `mise x -- tuist generate`
- Is idempotent and safe to run multiple times

## Format
Generate each file completely with its relative path as a heading.
