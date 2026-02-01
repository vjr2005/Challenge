# ChallengeDesignSystem

Atomic Design System providing reusable UI components and design tokens.

## Overview

ChallengeDesignSystem implements the Atomic Design methodology, organizing components into atoms, molecules, and organisms. It provides consistent design tokens for colors, typography, spacing, and other visual properties.

## Structure

```
DesignSystem/
├── Sources/
│   ├── Foundation/           # Design tokens
│   │   ├── Colors/
│   │   │   └── ColorToken.swift
│   │   ├── Typography/
│   │   │   └── TextStyle.swift
│   │   ├── Spacing/
│   │   │   └── SpacingToken.swift
│   │   ├── Corners/
│   │   │   └── CornerRadiusToken.swift
│   │   ├── Shadows/
│   │   │   └── ShadowToken.swift
│   │   ├── Icons/
│   │   │   └── IconSizeToken.swift
│   │   ├── Opacity/
│   │   │   └── OpacityToken.swift
│   │   └── Borders/
│   │       └── BorderWidthToken.swift
│   ├── Atoms/                # Basic components
│   │   ├── Buttons/
│   │   │   └── DSButton.swift
│   │   ├── Images/
│   │   │   ├── DSAsyncImage.swift
│   │   │   └── DSAvatar.swift
│   │   └── Indicators/
│   │       ├── DSBadge.swift
│   │       └── DSStatusIndicator.swift
│   ├── Molecules/            # Combined components
│   │   ├── DSInfoRow.swift
│   │   ├── DSLabeledValue.swift
│   │   └── DSStatusBadge.swift
│   ├── Organisms/            # Complex components
│   │   ├── Cards/
│   │   │   ├── DSCard.swift
│   │   │   └── DSListItemCard.swift
│   │   └── Feedback/
│   │       ├── DSLoadingView.swift
│   │       ├── DSEmptyState.swift
│   │       └── DSErrorView.swift
│   └── Extensions/
│       └── View+DesignSystem.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeDesignSystem` | Framework | UI components and tokens |
| `ChallengeDesignSystemTests` | Test | Unit and snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Image loader for async images |

## Design Tokens

### ColorToken

Semantic color definitions:

```swift
// Background
ColorToken.backgroundPrimary
ColorToken.backgroundSecondary
ColorToken.backgroundTertiary

// Text
ColorToken.textPrimary
ColorToken.textSecondary
ColorToken.textTertiary

// Status
ColorToken.statusSuccess    // Green
ColorToken.statusError      // Red
ColorToken.statusWarning    // Orange
ColorToken.statusNeutral    // Gray

// Interactive
ColorToken.accent
ColorToken.accentSubtle
ColorToken.disabled
```

### SpacingToken

Consistent spacing values:

```swift
SpacingToken.xxs   // 2pt
SpacingToken.xs    // 4pt
SpacingToken.sm    // 8pt
SpacingToken.md    // 12pt
SpacingToken.lg    // 16pt
SpacingToken.xl    // 24pt
SpacingToken.xxl   // 32pt
```

### TextStyle

Typography definitions:

```swift
TextStyle.largeTitle
TextStyle.title
TextStyle.headline
TextStyle.body
TextStyle.callout
TextStyle.caption
```

### CornerRadiusToken

Border radius values:

```swift
CornerRadiusToken.none
CornerRadiusToken.small
CornerRadiusToken.medium
CornerRadiusToken.large
CornerRadiusToken.full
```

## Components

### Atoms

Basic building blocks:

| Component | Description |
|-----------|-------------|
| `DSButton` | Button with variants (primary, secondary, etc.) |
| `DSAsyncImage` | Async image loading with placeholder |
| `DSAvatar` | Circular avatar image |
| `DSBadge` | Small label badge |
| `DSStatusIndicator` | Status dot indicator |

### Molecules

Combined atoms:

| Component | Description |
|-----------|-------------|
| `DSInfoRow` | Icon + label + value row |
| `DSLabeledValue` | Label above value |
| `DSStatusBadge` | Status indicator with label |

### Organisms

Complex components:

| Component | Description |
|-----------|-------------|
| `DSCard` | Generic card container |
| `DSListItemCard` | Card for list items with avatar |
| `DSLoadingView` | Loading spinner with message |
| `DSEmptyState` | Empty state with icon and message |
| `DSErrorView` | Error state with retry button |

## Usage

### Text

Use SwiftUI's native `Text` with `TextStyle` tokens:

```swift
Text("Hello World")
    .font(TextStyle.headline.font)
    .foregroundStyle(ColorToken.textPrimary)

Text("Subtitle")
    .font(TextStyle.body.font)
    .foregroundStyle(ColorToken.textSecondary)
```

### Button

```swift
DSButton("Primary", variant: .primary) {
    // Action
}

DSButton("Secondary", variant: .secondary) {
    // Action
}
```

### Avatar

```swift
DSAvatar(url: avatarURL, size: .medium)
DSAvatar(url: nil, size: .large, placeholder: "JD")
```

### Cards

```swift
DSCard {
    VStack {
        Text("Card Title")
            .font(TextStyle.headline.font)
            .foregroundStyle(ColorToken.textPrimary)
        Text("Card content")
            .font(TextStyle.body.font)
            .foregroundStyle(ColorToken.textPrimary)
    }
}

DSListItemCard(
    imageURL: avatarURL,
    title: "Character Name",
    subtitle: "Human - Alive"
)
```

### Feedback States

```swift
// Loading
DSLoadingView(message: "Loading...")

// Empty
DSEmptyState(
    icon: "person.slash",
    title: "No Characters",
    message: "No characters found"
)

// Error
DSErrorView(
    title: "Error",
    message: "Failed to load",
    retryAction: { /* retry */ }
)
```

## Testing

The module includes:

- **Unit tests** for token values and component behavior
- **Snapshot tests** for visual regression testing

Run tests with:

```bash
tuist test ChallengeDesignSystem
```
