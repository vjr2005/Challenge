# ChallengeDesignSystem

Atomic Design System providing reusable UI components and design tokens with themeable colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows via SwiftUI Environment.

## Overview

ChallengeDesignSystem implements the Atomic Design methodology, organizing components into atoms, molecules, and organisms. It provides consistent design tokens for colors, typography, spacing, dimensions, border widths, corner radii, opacity, shadows, and other visual properties. All tokens are themeable via the SwiftUI Environment (`@Environment(\.dsTheme)`).

## Structure

```
DesignSystem/
├── Sources/
│   ├── Theme/                # Theming system
│   │   ├── DSTheme.swift     # Theme struct
│   │   ├── DSThemeEnvironment.swift  # SwiftUI Environment
│   │   ├── Contracts/        # Theme protocols
│   │   │   ├── DSBorderWidth.swift
│   │   │   ├── DSColorPalette.swift
│   │   │   ├── DSCornerRadius.swift
│   │   │   ├── DSDimensions.swift
│   │   │   ├── DSOpacity.swift
│   │   │   ├── DSShadow.swift
│   │   │   ├── DSSpacing.swift
│   │   │   └── DSTypography.swift
│   │   └── Default/          # Default theme implementation
│   │       ├── DefaultBorderWidth.swift
│   │       ├── DefaultColorPalette.swift
│   │       ├── DefaultCornerRadius.swift
│   │       ├── DefaultDimensions.swift
│   │       ├── DefaultOpacity.swift
│   │       ├── DefaultShadow.swift
│   │       ├── DefaultSpacing.swift
│   │       └── DefaultTypography.swift
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

Colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows are accessed through the theme environment, enabling runtime theme switching.

### Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  DSTheme (struct, Sendable)                                  │
│  ┌──────────────┐ ┌────────────┐ ┌─────────┐ ┌────────────┐ ┌─────────────┐ ┌──────────────┐ ┌─────────┐ │
│  │DSColorPalette│ │DSTypography│ │DSSpacing│ │DSDimensions│ │DSBorderWidth│ │DSCornerRadius│ │DSOpacity│ │DSShadow│ │
│  │ (protocol)   │ │ (protocol) │ │(protocol)│ │ (protocol) │ │ (protocol)  │ │ (protocol)   │ │(protocol)│ │(protocol)│ │
│  └──────────────┘ └────────────┘ └─────────┘ └────────────┘ └─────────────┘ └──────────────┘ └─────────┘ └────────┘ │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
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
            .font(theme.typography.headline)
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
    typography: DefaultTypography(),
    spacing: DefaultSpacing(),
    dimensions: DefaultDimensions(),
    borderWidth: DefaultBorderWidth(),
    cornerRadius: DefaultCornerRadius(),
    opacity: DefaultOpacity(),
    shadow: DefaultShadow()
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
theme.typography.largeTitle   // .rounded, .bold
theme.typography.title        // .rounded, .bold
theme.typography.title2       // .rounded, .semibold
theme.typography.title3       // .rounded, .semibold
theme.typography.headline     // .rounded, .semibold
theme.typography.body         // .rounded
theme.typography.subheadline  // .serif
theme.typography.footnote     // .rounded
theme.typography.caption      // .rounded
theme.typography.caption2     // .monospaced
```

### DSSpacing (via theme)

Spacing values accessed via `theme.spacing`:

```swift
theme.spacing.xxs   // 2pt
theme.spacing.xs    // 4pt
theme.spacing.sm    // 8pt
theme.spacing.md    // 12pt
theme.spacing.lg    // 16pt
theme.spacing.xl    // 20pt
theme.spacing.xxl   // 24pt
theme.spacing.xxxl  // 32pt
```

### DSDimensions (via theme)

Dimension values for icons and other sized elements, accessed via `theme.dimensions`:

```swift
theme.dimensions.xs    // 8pt
theme.dimensions.sm    // 12pt
theme.dimensions.md    // 16pt
theme.dimensions.lg    // 24pt
theme.dimensions.xl    // 32pt
theme.dimensions.xxl   // 48pt
theme.dimensions.xxxl  // 56pt
```

### DSBorderWidth (via theme)

Border width values accessed via `theme.borderWidth`:

```swift
theme.borderWidth.hairline  // 0.5pt
theme.borderWidth.thin      // 1pt
theme.borderWidth.medium    // 2pt
theme.borderWidth.thick     // 4pt
```

### DSCornerRadius (via theme)

Corner radius values accessed via `theme.cornerRadius`:

```swift
theme.cornerRadius.zero  // 0pt
theme.cornerRadius.xs    // 4pt
theme.cornerRadius.sm    // 8pt
theme.cornerRadius.md    // 12pt
theme.cornerRadius.lg    // 16pt
theme.cornerRadius.xl    // 20pt
theme.cornerRadius.full  // 9999pt
```

### DSOpacity (via theme)

Opacity values accessed via `theme.opacity`:

```swift
theme.opacity.subtle        // 0.1
theme.opacity.light         // 0.15
theme.opacity.medium        // 0.4
theme.opacity.heavy         // 0.6
theme.opacity.almostOpaque  // 0.8
```

### DSShadow (via theme)

Shadow values accessed via `theme.shadow`:

```swift
theme.shadow.zero    // No shadow (clear, radius: 0, x: 0, y: 0)
theme.shadow.small   // Subtle card shadow (black 5%, radius: 8, x: 0, y: 2)
theme.shadow.medium  // Elevated elements (black 8%, radius: 12, x: 0, y: 4)
theme.shadow.large   // Floating elements (black 12%, radius: 20, x: 0, y: 8)
```

Each shadow level returns a `DSShadowValue` with `color`, `radius`, `x`, and `y` properties. Apply with the `.shadow(_:)` View extension:

```swift
.shadow(theme.shadow.small)
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
    .font(theme.typography.headline)
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
            .font(theme.typography.headline)
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
