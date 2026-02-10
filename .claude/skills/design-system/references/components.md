# DS Components

## Atoms

### Typography

Use SwiftUI's native `Text` with the theme for consistent typography:

```swift
@Environment(\.dsTheme) private var theme

// Basic usage
Text("Hello World")
    .font(theme.typography.headline)
    .foregroundStyle(theme.colors.textPrimary)

// With custom color
Text("Error message")
    .font(theme.typography.body)
    .foregroundStyle(theme.colors.statusError)

// With accessibility identifier
Text("Title")
    .font(theme.typography.headline)
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
            .font(theme.typography.headline)
            .foregroundStyle(theme.colors.textPrimary)
        Text("Card content")
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.textPrimary)
    }
}

// Customized
DSCard(padding: theme.spacing.xl, shadow: theme.shadow.medium) {
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

## Accessibility Identifier Propagation

| Component | Child Suffixes |
|-----------|---------------|
| `DSInfoRow` | `.icon`, `.label`, `.value` |
| `DSCardInfoRow` | `.image`, `.title`, `.subtitle`, `.caption`, `.status`, `.statusLabel` |
| `DSEmptyState` | `.icon`, `.title`, `.message`, `.button` |
| `DSErrorView` | `.icon`, `.title`, `.message`, `.button` |
| `DSLoadingView` | `.indicator`, `.message` |
