---
name: design-system
description: Atomic Design System for SwiftUI. Use when creating UI components, applying design tokens (colors, typography, spacing), or building consistent user interfaces.
---

# Skill: Design System

Guide for using the Atomic Design System to build consistent SwiftUI interfaces.

## When to use this skill

- Apply consistent colors, typography, or spacing
- Create UI components using atoms, molecules, or organisms
- Build views that follow design system patterns
- Replace hardcoded styling with design tokens

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## Module Structure

```
Libraries/DesignSystem/
├── Sources/
│   ├── Foundation/           # Design Tokens
│   │   ├── Theming/          # Theme contracts
│   │   │   ├── DSBorderWidth.swift
│   │   │   ├── DSColorPalette.swift
│   │   │   ├── DSCornerRadius.swift
│   │   │   ├── DSDimensions.swift
│   │   │   ├── DSOpacity.swift
│   │   │   ├── DSSpacing.swift
│   │   │   ├── DSTheme.swift
│   │   │   ├── DSThemeEnvironment.swift
│   │   │   └── DSTypography.swift
│   │   ├── Themes/           # Theme implementations
│   │   │   └── Default/
│   │   │       ├── DefaultBorderWidth.swift
│   │   │       ├── DefaultColorPalette.swift
│   │   │       ├── DefaultCornerRadius.swift
│   │   │       ├── DefaultDimensions.swift
│   │   │       ├── DefaultOpacity.swift
│   │   │       ├── DefaultSpacing.swift
│   │   │       └── DefaultTypography.swift
│   │   ├── Typography/
│   │   │   └── TextStyle.swift
│   │   └── Shadows/
│   │       └── ShadowToken.swift
│   │
│   ├── Atoms/                # Basic building blocks
│   │   ├── Buttons/
│   │   │   └── DSButton.swift
│   │   ├── Images/
│   │   │   └── DSAsyncImage.swift
│   │   └── Indicators/
│   │       └── DSStatusIndicator.swift
│   │
│   ├── Molecules/            # Combinations of atoms
│   │   ├── DSInfoRow.swift
│   │   └── DSCardInfoRow.swift
│   │
│   ├── Organisms/            # Complex components
│   │   ├── Cards/
│   │   │   └── DSCard.swift
│   │   └── Feedback/
│   │       ├── DSLoadingView.swift
│   │       ├── DSErrorView.swift
│   │       └── DSEmptyState.swift
│   │
│   └── Extensions/
│       └── View+DesignSystem.swift
│
└── Tests/
```

---

## Theming

Colors, typography, spacing, dimensions, border widths, corner radii, and opacity are accessed through the SwiftUI Environment via `@Environment(\.dsTheme)`. All DS components read the theme automatically. Geometric tokens (shadows) remain static.

### Reading the theme in a View

```swift
struct MyView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Text("Hello")
            .font(theme.typography.font(for: .headline))
            .foregroundStyle(theme.colors.textPrimary)
    }
}
```

### Applying a custom theme

```swift
ContentView()
    .dsTheme(customTheme)
```

### DSColorPalette (protocol)

Accessed via `theme.colors`:

```swift
theme.colors.backgroundPrimary    // Primary background
theme.colors.backgroundSecondary  // Secondary/grouped background
theme.colors.surfacePrimary       // Card/elevated surfaces
theme.colors.textPrimary          // Primary text
theme.colors.textSecondary        // Secondary text
theme.colors.textTertiary         // Tertiary text
theme.colors.statusSuccess        // Success (green)
theme.colors.statusError          // Error (red)
theme.colors.statusWarning        // Warning (orange)
theme.colors.statusNeutral        // Neutral (gray)
theme.colors.accent               // Accent color
theme.colors.accentSubtle         // Accent with opacity
```

---

## DSSpacing (via theme)

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

---

## DSDimensions (via theme)

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

---

## DSBorderWidth (via theme)

Border width values accessed via `theme.borderWidth`:

```swift
theme.borderWidth.hairline  // 0.5pt
theme.borderWidth.thin      // 1pt
theme.borderWidth.medium    // 2pt
theme.borderWidth.thick     // 4pt
```

---

## DSCornerRadius (via theme)

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

---

## Foundation: Static Design Tokens

### TextStyle

Enum cases for typography (input to `DSTypography`):

```swift
TextStyle.largeTitle  // .rounded, .bold
TextStyle.title       // .rounded, .bold
TextStyle.title2      // .rounded, .semibold
TextStyle.title3      // .rounded, .semibold
TextStyle.headline    // .rounded, .semibold
TextStyle.body        // .rounded
TextStyle.subheadline // .serif
TextStyle.footnote    // .rounded
TextStyle.caption     // .rounded
TextStyle.caption2    // .monospaced
```

### ShadowToken

```swift
ShadowToken.zero    // No shadow
ShadowToken.small   // Subtle card shadow
ShadowToken.medium  // Elevated elements
ShadowToken.large   // Floating elements
```

## DSOpacity (via theme)

Opacity values accessed via `theme.opacity`:

```swift
theme.opacity.subtle        // 0.1
theme.opacity.light         // 0.15
theme.opacity.medium        // 0.4
theme.opacity.heavy         // 0.6
theme.opacity.almostOpaque  // 0.8
```

---

## Atoms

### Typography with TextStyle

Use SwiftUI's native `Text` with the theme for consistent typography:

```swift
@Environment(\.dsTheme) private var theme

// Basic usage
Text("Hello World")
    .font(theme.typography.font(for: .headline))
    .foregroundStyle(theme.colors.textPrimary)

// With custom color
Text("Error message")
    .font(theme.typography.font(for: .body))
    .foregroundStyle(theme.colors.statusError)

// With accessibility identifier
Text("Title")
    .font(theme.typography.font(for: .headline))
    .foregroundStyle(theme.colors.textPrimary)
    .accessibilityIdentifier("screen.title")
```

### DSButton

Button with variants:

```swift
// Primary (filled)
DSButton("Submit") { /* action */ }

// Secondary (outlined)
DSButton("Cancel", variant: .secondary) { /* action */ }

// Tertiary (subtle background)
DSButton("Load More", icon: "arrow.down", variant: .tertiary) { /* action */ }

// Loading state
DSButton("Processing", isLoading: true) { /* action */ }

// With accessibility identifier
DSButton("Submit", accessibilityIdentifier: "form.submitButton") { /* action */ }
```

### DSStatusIndicator

Colored status circle:

```swift
DSStatusIndicator(status: .alive)           // Green circle
DSStatusIndicator(status: .dead, size: 8)   // Red circle, smaller
DSStatusIndicator(status: .unknown)         // Gray circle

// With accessibility identifier
DSStatusIndicator(status: .alive, accessibilityIdentifier: "character.status")
```

### DSStatus

`DSStatus` is a non-View enum. Colors are resolved via `color(in:)`:

```swift
let status = DSStatus.from("alive")
let color = status.color(in: theme.colors)
```

### DSAsyncImage

Async image with caching support (replaces `AsyncImage` for snapshot testing). Uses `AsyncImagePhase` for handling loading states.

**Simple usage (with default content):**

```swift
DSAsyncImage(url: character.imageURL)
    .frame(width: 70, height: 70)
    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
```

Default behavior: shows `ProgressView` while loading, error placeholder on failure, and `image.resizable().scaledToFill()` on success.

> **Note:** Uses `ImageLoaderContract` from Core via environment. For snapshot tests, inject `ImageLoaderMock` with `.imageLoader(mock)`.

---

## Molecules

### DSInfoRow

Icon + label + value layout:

```swift
DSInfoRow(icon: "person.fill", label: "Name", value: "Rick Sanchez")

// With custom icon color (defaults to theme.colors.accent)
DSInfoRow(icon: "heart.fill", label: "Status", value: "Alive", iconColor: .green)

// With accessibility identifier (propagates to children with suffixes)
DSInfoRow(
    icon: "person.fill",
    label: "Name",
    value: "Rick Sanchez",
    accessibilityIdentifier: "character.nameRow"
)
// Results in: .icon, .label, .value suffixes
```

### DSCardInfoRow

A row card component for displaying items with image, text content, and optional status:

```swift
DSCardInfoRow(
    imageURL: character.imageURL,
    title: character.name,
    subtitle: character.species,
    caption: character.location.name,
    captionIcon: "mappin.circle.fill",
    status: DSStatus.from(character.status.rawValue),
    statusLabel: character.status.rawValue,
    accessibilityIdentifier: "characterList.row.\(character.id)"
)
```

---

## Organisms

### DSCard

Generic card container:

```swift
DSCard {
    VStack {
        Text("Card Title")
            .font(theme.typography.font(for: .headline))
            .foregroundStyle(theme.colors.textPrimary)
        Text("Card content")
            .font(theme.typography.font(for: .body))
            .foregroundStyle(theme.colors.textPrimary)
    }
}

// Customized
DSCard(padding: theme.spacing.xl, shadow: .medium) {
    // content
}
```

### DSLoadingView

Loading state with optional message:

```swift
DSLoadingView()
DSLoadingView(message: "Loading characters...")

// With accessibility identifier
DSLoadingView(message: "Loading...", accessibilityIdentifier: "screen.loading")
// Results in: .indicator, .message suffixes
```

### DSErrorView

Error state with optional retry:

```swift
DSErrorView(title: "Something went wrong")

DSErrorView(
    title: "Connection Error",
    message: "Please check your internet connection.",
    retryTitle: "Retry",
    retryAction: {
        // retry action
    },
    accessibilityIdentifier: "screen.error"
)
// Results in: .icon, .title, .message, .button suffixes
```

### DSEmptyState

Empty state with icon and message:

```swift
DSEmptyState(
    icon: "person.slash",
    title: "No Characters",
    message: "There are no characters to display.",
    accessibilityIdentifier: "characterList.emptyState"
)
// Results in: .icon, .title, .message, .button suffixes
```

---

## DS Component Design Principles

DS components follow different conventions than feature Views:

| Aspect | Feature Views | DS Components |
|--------|---------------|---------------|
| **LocalizedStrings** | Private enum inside View | Not needed - receive text as parameters |
| **AccessibilityIdentifier** | Private enum inside View | Receive as parameter, propagate to children |
| **ViewModel** | Generic over contract | None - pure UI components |
| **Theme** | `@Environment(\.dsTheme)` | `@Environment(\.dsTheme)` (automatic) |
| **Previews** | One per ViewState | May be commented out for coverage |

DS components are **reusable building blocks** that receive all content (text, identifiers) from the calling View. The calling View is responsible for localization and accessibility identifier definitions.

---

## Accessibility Identifier Pattern

All DS components accept an optional `accessibilityIdentifier: String?` parameter. Molecules and organisms propagate this identifier to their child components with descriptive suffixes.

### Propagation Suffixes

| Component | Child Suffixes |
|-----------|---------------|
| `DSInfoRow` | `.icon`, `.label`, `.value` |
| `DSCardInfoRow` | `.image`, `.title`, `.subtitle`, `.caption`, `.status`, `.statusLabel` |
| `DSEmptyState` | `.icon`, `.title`, `.message`, `.button` |
| `DSErrorView` | `.icon`, `.title`, `.message`, `.button` |
| `DSLoadingView` | `.indicator`, `.message` |

---

## Migration Guide

### Before (hardcoded styles):

```swift
Text("Title")
    .font(.system(.headline, design: .rounded, weight: .semibold))
    .foregroundStyle(.primary)

.padding(16)
.background(Color(.systemBackground))
.clipShape(RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
```

### After (design system):

```swift
@Environment(\.dsTheme) private var theme

Text("Title")
    .font(theme.typography.font(for: .headline))
    .foregroundStyle(theme.colors.textPrimary)

DSCard {
    // content
}
```

---

## Import

```swift
import ChallengeDesignSystem
```

---

## Checklist

- [ ] Import `ChallengeDesignSystem`
- [ ] Add `@Environment(\.dsTheme) private var theme`
- [ ] Use `theme.colors.xxx` for colors
- [ ] Use `theme.typography.font(for: .xxx)` for fonts
- [ ] Use `theme.spacing.xxx` for spacing values
- [ ] Use `theme.dimensions.xxx` for icon and element sizes
- [ ] Use `theme.cornerRadius.xxx` for corner radii
- [ ] Use `theme.opacity.xxx` for opacity values
- [ ] Use `theme.borderWidth.xxx` for border widths
- [ ] Use `DSCard` for card styling
- [ ] Use `DSLoadingView`, `DSErrorView`, `DSEmptyState` for feedback states
- [ ] Use `DSStatus.color(in: theme.colors)` for status colors
- [ ] Pass `accessibilityIdentifier:` parameter for UI testing
