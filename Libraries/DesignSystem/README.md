# ChallengeDesignSystem

Atomic Design System providing reusable UI components and design tokens with themeable colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows via SwiftUI Environment.

## Overview

ChallengeDesignSystem implements the Atomic Design methodology, organizing components into atoms, molecules, and organisms. It provides consistent design tokens for colors, typography, spacing, dimensions, border widths, corner radii, opacity, shadows, and other visual properties. All tokens are themeable via the SwiftUI Environment (`@Environment(\.dsTheme)`).

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
DesignSystem/
├── Sources/
│   ├── Theme/                # Theming system
│   │   ├── DSTheme.swift     # Theme struct
│   │   ├── DSThemeEnvironment.swift  # SwiftUI Environment
│   │   ├── Contracts/        # Theme protocols
│   │   │   ├── DSBorderWidthContract.swift
│   │   │   ├── DSColorPaletteContract.swift
│   │   │   ├── DSCornerRadiusContract.swift
│   │   │   ├── DSDimensionsContract.swift
│   │   │   ├── DSOpacityContract.swift
│   │   │   ├── DSShadowContract.swift
│   │   │   ├── DSSpacingContract.swift
│   │   │   └── DSTypographyContract.swift
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
│   │   ├── Badges/
│   │   │   └── DSBadge.swift
│   │   ├── Buttons/
│   │   │   └── DSButton.swift
│   │   ├── Chips/
│   │   │   └── DSChip.swift
│   │   ├── Images/
│   │   │   ├── DSAsyncImage.swift
│   │   │   └── DSAsyncImageDefaultContentView.swift
│   │   ├── Indicators/
│   │   │   └── DSStatusIndicator.swift
│   │   └── TextFields/
│   │       └── DSTextField.swift
│   ├── Molecules/            # Combined components
│   │   ├── DSInfoRow.swift
│   │   ├── DSCardInfoRow.swift
│   │   └── DSChipGroup.swift
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
│                                  DSTheme (struct)                                  │
│  ┌──────────────┐ ┌────────────┐ ┌─────────┐ ┌────────────┐ ┌─────────────┐ ┌──────────────┐ ┌─────────┐ │
│  │DSColorPaletteContract│ │DSTypographyContract│ │DSSpacingContract│ │DSDimensionsContract│ │DSBorderWidthContract│ │DSCornerRadiusContract│ │DSOpacityContract│ │DSShadowContract│ │
│  │ (protocol)           │ │ (protocol)         │ │(protocol)       │ │ (protocol)         │ │ (protocol)          │ │ (protocol)           │ │(protocol)       │ │(protocol)      │ │
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

The `Default*` implementations are internal to the module. To create a fully custom theme, implement all contracts:

```swift
struct BrandColorPalette: DSColorPaletteContract {
    var accent: Color { .blue }
    // ... implement all color properties
}

struct BrandTypography: DSTypographyContract {
    // ... implement all typography properties
}

// Implement DSSpacingContract, DSDimensionsContract,
// DSBorderWidthContract, DSCornerRadiusContract,
// DSOpacityContract, DSShadowContract

let brandTheme = DSTheme(
    colors: BrandColorPalette(),
    typography: BrandTypography(),
    spacing: BrandSpacing(),
    dimensions: BrandDimensions(),
    borderWidth: BrandBorderWidth(),
    cornerRadius: BrandCornerRadius(),
    opacity: BrandOpacity(),
    shadow: BrandShadow()
)
```

For most cases, use the built-in default theme via `DSTheme.default`.

## Design Tokens

### DSColorPaletteContract (via theme)

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

### DSTypographyContract (via theme)

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

### DSSpacingContract (via theme)

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

### DSDimensionsContract (via theme)

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

### DSBorderWidthContract (via theme)

Border width values accessed via `theme.borderWidth`:

```swift
theme.borderWidth.hairline  // 0.5pt
theme.borderWidth.thin      // 1pt
theme.borderWidth.medium    // 2pt
theme.borderWidth.thick     // 4pt
```

### DSCornerRadiusContract (via theme)

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

### DSOpacityContract (via theme)

Opacity values accessed via `theme.opacity`:

```swift
theme.opacity.subtle        // 0.1
theme.opacity.light         // 0.15
theme.opacity.medium        // 0.4
theme.opacity.heavy         // 0.6
theme.opacity.almostOpaque  // 0.8
```

### DSShadowContract (via theme)

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
| `DSBadge` | Count badge overlay on any content |
| `DSButton` | Button with variants (primary, secondary, tertiary) |
| `DSChip` | Selectable chip with capsule shape |
| `DSAsyncImage` | Async image loading with caching |
| `DSStatusIndicator` | Status dot indicator |
| `DSTextField` | Styled text field with rounded shape |

### Molecules

| Component | Description |
|-----------|-------------|
| `DSInfoRow` | Icon + label + value row |
| `DSCardInfoRow` | Card with image, text, and status |
| `DSChipGroup` | Labeled horizontal group of selectable chips |

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
