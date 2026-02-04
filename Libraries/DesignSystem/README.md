# ChallengeDesignSystem

Atomic Design System providing reusable UI components and design tokens with themeable colors and typography via SwiftUI Environment.

## Overview

ChallengeDesignSystem implements the Atomic Design methodology, organizing components into atoms, molecules, and organisms. It provides consistent design tokens for colors, typography, spacing, and other visual properties. Colors and typography are themeable via the SwiftUI Environment (`@Environment(\.dsTheme)`), while geometric tokens (spacing, corners, borders, icons, opacity, shadows) remain static.

## Structure

```
DesignSystem/
├── Sources/
│   ├── Foundation/           # Design tokens
│   │   ├── Theming/          # Theme contracts
│   │   │   ├── DSColorPalette.swift
│   │   │   ├── DSTypography.swift
│   │   │   ├── DSTheme.swift
│   │   │   └── DSThemeEnvironment.swift
│   │   ├── Themes/           # Theme implementations
│   │   │   └── Default/
│   │   │       ├── DefaultColorPalette.swift
│   │   │       └── DefaultTypography.swift
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
│   │   │   └── DSAsyncImage.swift
│   │   └── Indicators/
│   │       └── DSStatusIndicator.swift
│   ├── Molecules/            # Combined components
│   │   ├── DSInfoRow.swift
│   │   └── DSCardInfoRow.swift
│   ├── Organisms/            # Complex components
│   │   ├── Cards/
│   │   │   └── DSCard.swift
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

## Theming

Colors and typography are accessed through the theme environment, enabling runtime theme switching.

### Architecture

```
┌─────────────────────────────────────────────┐
│         DSTheme (struct, Sendable)          │
│  ┌───────────────┐  ┌───────────────────┐   │
│  │ DSColorPalette│  │  DSTypography     │   │
│  │  (protocol)   │  │  (protocol)       │   │
│  └───────────────┘  └───────────────────┘   │
└─────────────────────────────────────────────┘
                    │
        SwiftUI Environment (.dsTheme)
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
 DSButton      DSCard         DSInfoRow ...
 @Environment  @Environment   @Environment
```

### Usage

```swift
// Root of the app (optional - defaults to DSTheme.default)
ContentView()
    .dsTheme(customTheme)

// Components read from environment automatically
struct MyView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Text("Hello")
            .font(theme.typography.font(for: .headline))
            .foregroundStyle(theme.colors.textPrimary)
    }
}
```

### Creating a Custom Theme

```swift
struct BrandColorPalette: DSColorPalette {
    var accent: Color { .blue }
    // ... implement all 18 color properties
}

let brandTheme = DSTheme(
    colors: BrandColorPalette(),
    typography: DefaultTypography()
)
```

## Design Tokens

### DSColorPalette (via theme)

Semantic color definitions accessed via `theme.colors`:

```swift
@Environment(\.dsTheme) private var theme

// Background
theme.colors.backgroundPrimary
theme.colors.backgroundSecondary
theme.colors.backgroundTertiary

// Text
theme.colors.textPrimary
theme.colors.textSecondary
theme.colors.textTertiary

// Status
theme.colors.statusSuccess    // Green
theme.colors.statusError      // Red
theme.colors.statusWarning    // Orange
theme.colors.statusNeutral    // Gray

// Interactive
theme.colors.accent
theme.colors.accentSubtle
theme.colors.disabled
```

### DSTypography (via theme)

Typography accessed via `theme.typography`:

```swift
theme.typography.font(for: .headline)
theme.typography.font(for: .body)
theme.typography.defaultColor(for: .headline, in: theme.colors)
```

### TextStyle

Enum cases for typography styles (input to `DSTypography`):

```swift
TextStyle.largeTitle   // .rounded, .bold
TextStyle.title        // .rounded, .bold
TextStyle.headline     // .rounded, .semibold
TextStyle.body         // .rounded
TextStyle.subheadline  // .serif
TextStyle.caption      // .rounded
TextStyle.caption2     // .monospaced
```

### SpacingToken (static)

```swift
SpacingToken.xxs   // 2pt
SpacingToken.xs    // 4pt
SpacingToken.sm    // 8pt
SpacingToken.md    // 12pt
SpacingToken.lg    // 16pt
SpacingToken.xl    // 20pt
SpacingToken.xxl   // 24pt
SpacingToken.xxxl  // 32pt
```

### CornerRadiusToken (static)

```swift
CornerRadiusToken.zero  // 0pt
CornerRadiusToken.xs    // 4pt
CornerRadiusToken.sm    // 8pt
CornerRadiusToken.md    // 12pt
CornerRadiusToken.lg    // 16pt
CornerRadiusToken.xl    // 20pt
CornerRadiusToken.full  // 9999pt
```

## Components

### Atoms

| Component | Description |
|-----------|-------------|
| `DSButton` | Button with variants (primary, secondary, tertiary) |
| `DSAsyncImage` | Async image loading with caching |
| `DSStatusIndicator` | Status dot indicator |

### Molecules

| Component | Description |
|-----------|-------------|
| `DSInfoRow` | Icon + label + value row |
| `DSCardInfoRow` | Card with image, text, and status |

### Organisms

| Component | Description |
|-----------|-------------|
| `DSCard` | Generic card container |
| `DSLoadingView` | Loading spinner with message |
| `DSEmptyState` | Empty state with icon and message |
| `DSErrorView` | Error state with retry button |

## Usage

### Text

```swift
@Environment(\.dsTheme) private var theme

Text("Hello World")
    .font(theme.typography.font(for: .headline))
    .foregroundStyle(theme.colors.textPrimary)
```

### Button

```swift
DSButton("Primary") { /* action */ }
DSButton("Secondary", variant: .secondary) { /* action */ }
```

### Cards

```swift
DSCard {
    VStack {
        Text("Card Title")
            .font(theme.typography.font(for: .headline))
            .foregroundStyle(theme.colors.textPrimary)
    }
}
```

### Feedback States

```swift
DSLoadingView(message: "Loading...")

DSEmptyState(
    icon: "person.slash",
    title: "No Characters",
    message: "No characters found"
)

DSErrorView(
    title: "Error",
    message: "Failed to load",
    retryTitle: "Retry",
    retryAction: { /* retry */ }
)
```

## Testing

The module includes:

- **Unit tests** for token values, palette parity, and typography
- **Snapshot tests** for visual regression testing

Run tests with:

```bash
mise x -- tuist test
```
