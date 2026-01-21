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
│   │   └── Corners/
│   │       └── CornerRadiusToken.swift
│   │
│   ├── Atoms/                # Basic building blocks
│   │   ├── Text/
│   │   │   └── DSText.swift
│   │   ├── Buttons/
│   │   │   └── DSButton.swift
│   │   ├── Images/
│   │   │   ├── DSAvatar.swift
│   │   │   └── DSAsyncImage.swift
│   │   └── Indicators/
│   │       ├── DSStatusIndicator.swift
│   │       └── DSBadge.swift
│   │
│   ├── Molecules/            # Combinations of atoms
│   │   ├── DSInfoRow.swift
│   │   ├── DSStatusBadge.swift
│   │   └── DSLabeledValue.swift
│   │
│   ├── Organisms/            # Complex components
│   │   ├── Cards/
│   │   │   ├── DSCard.swift
│   │   │   └── DSListItemCard.swift
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

### DSBadge

Badge with semantic colors:

```swift
DSBadge("Active", variant: .success)
DSBadge("Failed", variant: .error)
DSBadge("Pending", variant: .neutral)
```

### DSAsyncImage

Async image with caching support (replaces `AsyncImage` for snapshot testing):

```swift
DSAsyncImage(url: character.imageURL) { image in
    image.resizable().scaledToFill()
} placeholder: {
    ProgressView()
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

### DSStatusBadge

Status indicator with label:

```swift
DSStatusBadge(status: .alive)                    // Shows "Alive" with green indicator
DSStatusBadge(status: .dead, label: "Deceased")  // Custom label
```

### DSLabeledValue

Label-value pair:

```swift
DSLabeledValue(label: "Species", value: "Human")
DSLabeledValue(label: "Gender", value: "Male", orientation: .horizontal)
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

### DSListItemCard

List item with leading, info, and trailing sections:

```swift
DSListItemCard(
    title: "Rick Sanchez",
    subtitle: "Human",
    caption: "Earth (C-137)"
) {
    DSAsyncAvatar(url: imageURL, size: .medium)
} trailing: {
    DSStatusBadge(status: .alive)
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

## Checklist

- [ ] Import `ChallengeDesignSystem`
- [ ] Replace hardcoded colors with `ColorToken`
- [ ] Replace spacing values with `SpacingToken`
- [ ] Replace fonts with `TextStyle` or `DSText`
- [ ] Replace card styling with `DSCard`
- [ ] Replace loading views with `DSLoadingView`
- [ ] Replace error views with `DSErrorView`
- [ ] Replace empty views with `DSEmptyState`
- [ ] Use semantic status colors (`DSStatus`)
