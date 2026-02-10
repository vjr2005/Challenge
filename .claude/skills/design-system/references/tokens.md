# Theme Tokens

All design tokens accessed via `@Environment(\.dsTheme) private var theme`.

---

## DSColorPaletteContract

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

## DSSpacingContract

Accessed via `theme.spacing`:

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

## DSDimensionsContract

Accessed via `theme.dimensions`:

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

## DSBorderWidthContract

Accessed via `theme.borderWidth`:

```swift
theme.borderWidth.hairline  // 0.5pt
theme.borderWidth.thin      // 1pt
theme.borderWidth.medium    // 2pt
theme.borderWidth.thick     // 4pt
```

---

## DSCornerRadiusContract

Accessed via `theme.cornerRadius`:

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

## DSTypographyContract

Accessed via `theme.typography`:

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

---

## DSOpacityContract

Accessed via `theme.opacity`:

```swift
theme.opacity.subtle        // 0.1
theme.opacity.light         // 0.15
theme.opacity.medium        // 0.4
theme.opacity.heavy         // 0.6
theme.opacity.almostOpaque  // 0.8
```

---

## DSShadowContract

Accessed via `theme.shadow`. Each level returns a `DSShadowValue` with `color`, `radius`, `x`, and `y`:

```swift
theme.shadow.zero    // No shadow (clear, radius: 0, x: 0, y: 0)
theme.shadow.small   // Subtle card shadow (black 5%, radius: 8, x: 0, y: 2)
theme.shadow.medium  // Elevated elements (black 8%, radius: 12, x: 0, y: 4)
theme.shadow.large   // Floating elements (black 12%, radius: 20, x: 0, y: 8)
```

Apply with the `.shadow(_:)` View extension:

```swift
.shadow(theme.shadow.small)
```
