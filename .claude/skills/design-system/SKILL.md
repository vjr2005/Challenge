---
name: design-system
description: Atomic Design System for SwiftUI. Use when creating UI components, applying design tokens (colors, typography, spacing), or building consistent user interfaces.
---

# Skill: Design System

Guide for using the Atomic Design System to build consistent SwiftUI interfaces.

## References

- **Theme tokens** (colors, spacing, typography, etc.): See [references/tokens.md](references/tokens.md)
- **Component API** (atoms, molecules, organisms): See [references/components.md](references/components.md)
- **Full view examples**: See [references/view-examples.md](references/view-examples.md)

---

## Module Structure

```
Libraries/DesignSystem/
├── Sources/
│   ├── Theme/                # Theming system
│   │   ├── DSTheme.swift
│   │   ├── DSThemeEnvironment.swift
│   │   ├── Contracts/        # Theme protocols
│   │   └── Default/          # Default theme implementation
│   ├── Atoms/                # Basic building blocks
│   │   ├── Buttons/DSButton.swift
│   │   ├── Images/DSAsyncImage.swift
│   │   └── Indicators/DSStatusIndicator.swift
│   ├── Molecules/            # Combinations of atoms
│   │   ├── DSInfoRow.swift
│   │   └── DSCardInfoRow.swift
│   ├── Organisms/            # Complex components
│   │   ├── Cards/DSCard.swift
│   │   └── Feedback/
│   │       ├── DSLoadingView.swift
│   │       ├── DSErrorView.swift
│   │       └── DSEmptyState.swift
│   └── Extensions/
│       └── View+DesignSystem.swift
└── Tests/
```

---

## Theming

Colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows are accessed through the SwiftUI Environment via `@Environment(\.dsTheme)`. All DS components read the theme automatically.

### Reading the theme in a View

```swift
struct MyView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Text("Hello")
            .font(theme.typography.headline)
            .foregroundStyle(theme.colors.textPrimary)
    }
}
```

### Applying a custom theme

```swift
ContentView()
    .dsTheme(customTheme)
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
    .font(theme.typography.headline)
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
- [ ] Use `theme.typography.xxx` for fonts
- [ ] Use `theme.spacing.xxx` for spacing values
- [ ] Use `theme.dimensions.xxx` for icon and element sizes
- [ ] Use `theme.cornerRadius.xxx` for corner radii
- [ ] Use `theme.opacity.xxx` for opacity values
- [ ] Use `theme.borderWidth.xxx` for border widths
- [ ] Use `theme.shadow.xxx` for shadows
- [ ] Use `DSCard` for card styling
- [ ] Use `DSLoadingView`, `DSErrorView`, `DSEmptyState` for feedback states
- [ ] Use `DSStatus.color(in: theme.colors)` for status colors
- [ ] Pass `accessibilityIdentifier:` parameter for UI testing
