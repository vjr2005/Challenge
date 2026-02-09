# AI-Assisted Development

This project is configured for AI-assisted development using [Claude Code](https://claude.ai/claude-code).

## CLAUDE.md

The [CLAUDE.md](../CLAUDE.md) file defines coding standards, architecture patterns, and development practices that the AI must follow. It includes:

- Project guidelines and critical rules
- Architecture overview (MVVM + Clean Architecture)
- SOLID principles enforcement
- Testing requirements
- Code style conventions

## Skills

Skills are specialized prompts that guide the AI in specific tasks. They ensure consistency and adherence to project patterns.

### Code Generation

| Skill | Description |
|-------|-------------|
| `/view` | Creates SwiftUI Views with ViewModel integration and previews |
| `/viewmodel` | Creates ViewModels with ViewState pattern and state management |
| `/usecase` | Creates UseCases that encapsulate business logic |
| `/repository` | Creates Repositories that abstract data access with DTO-to-Domain mapping |
| `/datasource` | Creates DataSources for REST APIs (Remote) or in-memory storage (Memory) |
| `/navigator` | Creates Navigator for navigation and deep linking |
| `/dependency-injection` | Creates Features for dependency injection and wiring |

### UI & Design

| Skill | Description |
|-------|-------------|
| `/design-system` | Atomic Design System components, design tokens (colors, typography, spacing) |

### Testing

| Skill | Description |
|-------|-------------|
| `/testing` | Unit testing patterns with Swift Testing, Given/When/Then structure |
| `/ui-tests` | UI tests with Robot pattern and accessibility identifiers |
| `/snapshot` | Snapshot tests for SwiftUI Views using ChallengeSnapshotTestKit |

### Code Quality

| Skill | Description |
|-------|-------------|
| `/style-guide` | Code style, formatting rules, and naming conventions |
| `/concurrency` | Swift 6 concurrency: async/await, actors, MainActor, Sendable |
| `/clean-code` | Dead code detection and removal using Periphery |

### Project Configuration

| Skill | Description |
|-------|-------------|
| `/tuist` | Tuist configuration, xcframeworks, dependencies, Project.swift |
| `/project-structure` | Directory organization and feature modules |
| `/resources` | Resources module: localization and String extensions |

## Usage

Invoke a skill by typing its name in the chat:

```
/viewmodel
```

The AI will then follow the skill's guidelines to generate code that adheres to project standards.
