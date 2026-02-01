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
│   │   ├── Text/
│   │   │   └── DSText.swift
│   │   ├── Buttons/
│   │   │   └── DSButton.swift
│   │   ├── Images/
│   │   │   └── DSAsyncImage.swift
│   │   └── Indicators/
│   │       └── DSStatusIndicator.swift
│   │
│   ├── Molecules/            # Combinations of atoms
│   │   └── DSInfoRow.swift
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

### DSText

Text component with design system styles:

```swift
// Basic usage
DSText("Hello World", style: .headline)

// With custom color
DSText("Error message", style: .body, color: ColorToken.statusError)
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
```

### DSStatusIndicator

Colored status circle:

```swift
DSStatusIndicator(status: .alive)           // Green circle
DSStatusIndicator(status: .dead, size: 8)   // Red circle, smaller
DSStatusIndicator(status: .unknown)         // Gray circle
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
```

---

## Organisms

### DSCard

Generic card container:

```swift
DSCard {
    VStack {
        DSText("Card Title", style: .headline)
        DSText("Card content", style: .body)
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
```

### DSErrorView

Error state with optional retry:

```swift
DSErrorView(title: "Something went wrong")

DSErrorView(
    title: "Connection Error",
    message: "Please check your internet connection.",
    retryTitle: "Retry"
) {
    // retry action
}
```

### DSEmptyState

Empty state with icon and message:

```swift
DSEmptyState(
    icon: "person.slash",
    title: "No Characters",
    message: "There are no characters to display."
)
```

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
DSText("Title", style: .headline)

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

## Molecules

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
    statusLabel: character.status.rawValue
)
.dsAccessibilityIdentifier("characterList.row.\(character.id)")
```

Parameters:
- `imageURL`: URL of the image to display
- `title`: Main title text (required)
- `subtitle`: Optional subtitle text
- `caption`: Optional caption text below subtitle
- `captionIcon`: Optional SF Symbol for caption
- `status`: Optional `DSStatus` indicator
- `statusLabel`: Optional label below status indicator

---

## Accessibility Identifier Propagation

DS components automatically propagate accessibility identifiers from parent views with descriptive suffixes.

### Setting up propagation

Use `dsAccessibilityIdentifier(_:)` on parent views:

```swift
ForEach(characters, id: \.id) { character in
    DSCardInfoRow(
        imageURL: character.imageURL,
        title: character.name,
        status: DSStatus.from(character.status.rawValue)
    )
    .dsAccessibilityIdentifier("characterList.row.\(character.id)")
}
```

### Result

The identifier propagates to child DS components with suffixes:
- Container: `characterList.row.1`
- `DSAsyncImage`: `characterList.row.1.image`
- `DSText` (title): `characterList.row.1.title`
- `DSStatusIndicator`: `characterList.row.1.status`

### Custom suffixes

DS components accept custom suffixes:

```swift
DSText("Name", style: .headline, accessibilitySuffix: "name")
DSAsyncImage(url: url, accessibilitySuffix: "avatar")
DSStatusIndicator(status: .alive, accessibilitySuffix: "healthStatus")
```

### Default suffixes

| Component | Default Suffix |
|-----------|---------------|
| `DSText` | `text` |
| `DSAsyncImage` | `image` |
| `DSStatusIndicator` | `status` |
| `DSButton` | `button` |

---

## Checklist

- [ ] Import `ChallengeDesignSystem`
- [ ] Replace hardcoded colors with `ColorToken`
- [ ] Replace spacing values with `SpacingToken`
- [ ] Replace icon sizes with `IconSizeToken`
- [ ] Replace opacity values with `OpacityToken`
- [ ] Replace border widths with `BorderWidthToken`
- [ ] Replace fonts with `TextStyle` or `DSText`
- [ ] Replace card styling with `DSCard`
- [ ] Replace loading views with `DSLoadingView`
- [ ] Replace error views with `DSErrorView`
- [ ] Replace empty views with `DSEmptyState`
- [ ] Use semantic status colors (`DSStatus`)
- [ ] Use `DSCardInfoRow` for list item cards
- [ ] Apply `.dsAccessibilityIdentifier()` for E2E testing
