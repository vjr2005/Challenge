# Prompt Phase 0 — Migration context and orchestration

## What is this migration?

You are going to help migrate an iOS project that currently uses **Swift Package Manager (SPM) with local packages** to use **Tuist as the project orchestration layer**. Tuist will generate the `.xcodeproj` / `.xcworkspace` from a declarative Swift manifest (`Project.swift`, `Workspace.swift`), replacing the manually maintained Xcode project while keeping SPM for dependency resolution.

The goal is NOT to replace SPM — it is to add Tuist on top so the project structure, build settings, schemes, and CI pipelines are defined in code and reproducible.

## Reference projects

- **Primary**: [Challenge](https://github.com/vjr2005/Challenge) — a working Tuist-based iOS project. Use it as reference for Tuist API syntax, helper patterns, and project structure. Do NOT copy its configurations, bundle IDs, modules, or dependencies — adapt the patterns to the project being migrated.
- **Secondary**: [mastodon-ios-tuist](https://github.com/tuist/mastodon-ios-tuist) — useful to cross-check Tuist API usage or resolve doubts about advanced configurations.

## Migration phases

The migration is divided into 8 sequential phases. Each phase has its own prompt file with detailed instructions.

| # | Prompt file | Phase | Description |
|---|-------------|-------|-------------|
| 1 | `01-audit.md` | Audit | Run `scripts/audit.sh`, analyze the project, and generate a complete `AUDIT_REPORT.md` with all data needed for subsequent phases |
| 2 | `02-base-structure.md` | Base structure | Generate `Tuist.swift`, `Tuist/Package.swift`, and `.gitignore` based on the audit report |
| 3 | `03-helpers.md` | Helpers | Generate all `ProjectDescriptionHelpers` (extensions, factories, shared settings) |
| 4 | `04-generation.md` | Generation | Generate `Project.swift`, `Workspace.swift`, and `generate.sh`; run the first `tuist generate` |
| 5 | `05-schemes.md` | Schemes | Run `scripts/compare_schemes.sh`, compare generated vs original schemes, and fix discrepancies |
| 6 | `06-ci.md` | CI | Adapt CI/CD pipelines (GitHub Actions, etc.) to use Tuist + mise |
| 7 | `07-cache.md` | Cache | Run `scripts/extract_cache_data.sh` and optimize dependency cache configuration with `productTypes` |
| 8 | `08-validation.md` | Validation | Run `scripts/compare_settings.sh` and `scripts/validate_migration.sh`; do an automated diff of build settings and end-to-end validation |

## Interactive workflow

Follow this flow for each phase:

1. **Load the phase prompt** — Read the corresponding prompt file (`references/prompts/0X-*.md`) and follow its instructions completely.
2. **Execute the phase** — Run scripts, generate files, and perform all actions described in the prompt.
3. **Present the result** — Show the user a summary of what was done: files created/modified, key decisions made, and any warnings or issues found.
4. **Ask for feedback** — Ask the user if they want to modify anything before moving on. Apply changes if requested.
5. **Confirm continuation** — Once the user gives the go-ahead, ask: *"Ready to continue with Phase N+1 (phase name)?"*
6. **Repeat** — Move to the next phase and start from step 1.

Do NOT skip phases or execute multiple phases at once without explicit user approval.

After completing all 8 phases, inform the user that the migration is done.

## General rules

These rules apply across all phases:

- **Data source**: All project-specific data (targets, dependencies, build settings, schemes, bundle IDs) must come from the **audit report** generated in Phase 1, not from the reference projects.
- **No config copying**: Never copy configurations, bundle identifiers, team IDs, or dependency lists from the Challenge reference project. Only use it for Tuist API patterns and structural conventions.
- **Preserve behavior**: The migrated project must compile and behave identically to the original. No features should be added, removed, or changed during migration.
- **Incremental validation**: After each phase that produces compilable output (phases 4+), verify that `tuist generate` succeeds and the project builds.
- **Transparency**: If something is ambiguous or there are multiple valid approaches, explain the options and let the user decide instead of choosing silently.
