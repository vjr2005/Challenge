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
│   │   ├── Colors/
│   │   │   └── ColorToken.swift
│   │   ├── Typography/
│   │   │   └── TextStyle.swift
│   │   ├── Spacing/
│   │   │   └── SpacingToken.swift
│   │   ├── Shadows/
│   │   │   └── ShadowToken.swift
│   │   ├── Corners/
│   │   │   └── CornerRadiusToken.swift
│   │   ├── Icons/
│   │   │   └── IconSizeToken.swift
│   │   ├── Opacity/
│   │   │   └── OpacityToken.swift
│   │   └── Borders/
│   │       └── BorderWidthToken.swift
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

## Foundation: Design Tokens

### ColorToken

Semantic color definitions for consistent theming:

```swift
ColorToken.backgroundPrimary    // Primary background
ColorToken.backgroundSecondary  // Secondary/grouped background
ColorToken.surfacePrimary       // Card/elevated surfaces
ColorToken.textPrimary          // Primary text
ColorToken.textSecondary        // Secondary text
ColorToken.textTertiary         // Tertiary text
ColorToken.statusSuccess        // Success (green)
ColorToken.statusError          // Error (red)
ColorToken.statusWarning        // Warning (orange)
ColorToken.statusNeutral        // Neutral (gray)
ColorToken.accent               // Accent color
ColorToken.accentSubtle         // Accent with opacity
```

### SpacingToken

Consistent spacing values:

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

### TextStyle

Typography definitions with semantic names:

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

### CornerRadiusToken

```swift
CornerRadiusToken.none  // 0pt
CornerRadiusToken.xs    // 4pt
CornerRadiusToken.sm    // 8pt
CornerRadiusToken.md    // 12pt
CornerRadiusToken.lg    // 16pt
CornerRadiusToken.xl    // 20pt
CornerRadiusToken.full  // 9999pt (circular)
```

### ShadowToken

```swift
ShadowToken.zero    // No shadow
ShadowToken.small   // Subtle card shadow
ShadowToken.medium  // Elevated elements
ShadowToken.large   // Floating elements
```

### IconSizeToken

Consistent icon sizes:

```swift
IconSizeToken.xs    // 8pt
IconSizeToken.sm    // 12pt
IconSizeToken.md    // 16pt
IconSizeToken.lg    // 24pt
IconSizeToken.xl    // 32pt
IconSizeToken.xxl   // 48pt
IconSizeToken.xxxl  // 56pt
```

### OpacityToken

Opacity values for consistent transparency:

```swift
OpacityToken.subtle        // 0.1
OpacityToken.light         // 0.15
OpacityToken.medium        // 0.4
OpacityToken.heavy         // 0.6
OpacityToken.almostOpaque  // 0.8
```

### BorderWidthToken

Border and stroke widths:

```swift
BorderWidthToken.hairline  // 0.5pt
BorderWidthToken.thin      // 1pt
BorderWidthToken.medium    // 2pt
BorderWidthToken.thick     // 4pt
```

---

## Atoms

### Typography with TextStyle

Use SwiftUI's native `Text` with `TextStyle` tokens for consistent typography:

```swift
// Basic usage
Text("Hello World")
    .font(TextStyle.headline.font)
    .foregroundStyle(ColorToken.textPrimary)

// With custom color
Text("Error message")
    .font(TextStyle.body.font)
    .foregroundStyle(ColorToken.statusError)

// With accessibility identifier
Text("Title")
    .font(TextStyle.headline.font)
    .foregroundStyle(ColorToken.textPrimary)
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

### DSAsyncImage

Async image with caching support (replaces `AsyncImage` for snapshot testing). Uses `AsyncImagePhase` for handling loading states.

**Simple usage (with default content):**

```swift
DSAsyncImage(url: character.imageURL)
    .frame(width: 70, height: 70)
    .clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
```

Default behavior: shows `ProgressView` while loading, error placeholder on failure, and `image.resizable().scaledToFill()` on success.

**Custom content:**

```swift
DSAsyncImage(url: character.imageURL) { phase in
    switch phase {
    case .success(let image):
        image.resizable().scaledToFill()
    case .empty:
        ProgressView()
    case .failure:
        ZStack {
            ColorToken.surfaceSecondary
            Image(systemName: "photo")
                .foregroundStyle(ColorToken.textTertiary)
        }
    @unknown default:
        ProgressView()
    }
}
.frame(width: 70, height: 70)
.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
```

> **Note:** Uses `ImageLoaderContract` from Core via environment. For snapshot tests, inject `ImageLoaderMock` with `.imageLoader(mock)`.

---

## Molecules

### DSInfoRow

Icon + label + value layout:

```swift
DSInfoRow(icon: "person.fill", label: "Name", value: "Rick Sanchez")
DSInfoRow(icon: "heart.fill", label: "Status", value: "Alive", iconColor: ColorToken.statusSuccess)

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

Parameters:
- `imageURL`: URL of the image to display
- `title`: Main title text (required)
- `subtitle`: Optional subtitle text
- `caption`: Optional caption text below subtitle
- `captionIcon`: Optional SF Symbol for caption
- `status`: Optional `DSStatus` indicator
- `statusLabel`: Optional label below status indicator
- `accessibilityIdentifier`: Optional identifier (propagates to children)

---

## Organisms

### DSCard

Generic card container:

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

// Customized
DSCard(padding: SpacingToken.xl, shadow: .medium) {
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

## Accessibility Identifier Pattern

All DS components accept an optional `accessibilityIdentifier: String?` parameter. Molecules and organisms propagate this identifier to their child components with descriptive suffixes.

### Usage

Pass the identifier directly in the constructor:

```swift
ForEach(characters, id: \.id) { character in
    DSCardInfoRow(
        imageURL: character.imageURL,
        title: character.name,
        status: DSStatus.from(character.status.rawValue),
        accessibilityIdentifier: "characterList.row.\(character.id)"
    )
}
```

### Propagation Suffixes

When you pass `accessibilityIdentifier: "characterList.row.1"`:

| Component | Resulting Identifier |
|-----------|---------------------|
| Container | `characterList.row.1` |
| Image | `characterList.row.1.image` |
| Title | `characterList.row.1.title` |
| Status | `characterList.row.1.status` |

### Suffix Reference by Component

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
Text("Title")
    .font(TextStyle.headline.font)
    .foregroundStyle(ColorToken.textPrimary)

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
- [ ] Replace hardcoded colors with `ColorToken`
- [ ] Replace spacing values with `SpacingToken`
- [ ] Replace icon sizes with `IconSizeToken`
- [ ] Replace opacity values with `OpacityToken`
- [ ] Replace border widths with `BorderWidthToken`
- [ ] Replace fonts with `TextStyle.{style}.font`
- [ ] Replace card styling with `DSCard`
- [ ] Replace loading views with `DSLoadingView`
- [ ] Replace error views with `DSErrorView`
- [ ] Replace empty views with `DSEmptyState`
- [ ] Use semantic status colors (`DSStatus`)
- [ ] Use `DSCardInfoRow` for list item cards
- [ ] Pass `accessibilityIdentifier:` parameter for UI testing
