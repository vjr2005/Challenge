# Design System Examples

## Complete View Using Design System

```swift
import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
    @State private var viewModel: ViewModel
    @Environment(\.dsTheme) private var theme

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .onFirstAppear { await viewModel.load() }
            .navigationTitle(LocalizedStrings.title)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            DSLoadingView(message: LocalizedStrings.loading)
        case .loaded(let page):
            characterList(page: page)
        case .empty:
            DSEmptyState(
                icon: "person.slash",
                title: LocalizedStrings.Empty.title,
                message: LocalizedStrings.Empty.description
            )
            .accessibilityIdentifier(AccessibilityIdentifier.emptyState)
        case .error(let error):
            DSErrorView(
                title: LocalizedStrings.Error.title,
                message: error.localizedDescription
            )
        }
    }

    func characterList(page: CharactersPage) -> some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.lg) {
                headerView(totalCount: page.totalCount)

                ForEach(page.characters, id: \.id) { character in
                    DSCardInfoRow(
                        imageURL: character.imageURL,
                        title: character.name,
                        subtitle: character.species,
                        caption: character.location.name,
                        captionIcon: "mappin.circle.fill",
                        status: DSStatus.from(character.status.rawValue),
                        statusLabel: character.status.rawValue
                    )
                    .dsAccessibilityIdentifier(AccessibilityIdentifier.row(id: character.id))
                    .onTapGesture { viewModel.didSelect(character) }
                }

                if page.hasNextPage {
                    DSButton(
                        LocalizedStrings.loadMore,
                        icon: "arrow.down.circle.fill",
                        variant: .tertiary
                    ) {
                        Task { await viewModel.loadMore() }
                    }
                    .accessibilityIdentifier(AccessibilityIdentifier.loadMoreButton)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
        .background(theme.colors.backgroundSecondary)
    }

    func headerView(totalCount: Int) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(LocalizedStrings.headerTitle)
                .font(theme.typography.largeTitle)
                .foregroundStyle(theme.colors.textPrimary)
            Text(LocalizedStrings.headerSubtitle(totalCount))
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"
    static let loadMoreButton = "characterList.loadMoreButton"
    static let emptyState = "characterList.emptyState"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}
```

---

## Detail View with Cards

```swift
@Environment(\.dsTheme) private var theme

func infoCard(_ character: Character) -> some View {
    DSCard(padding: theme.spacing.xl) {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text(LocalizedStrings.information)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)

            VStack(spacing: theme.spacing.md) {
                DSInfoRow(icon: "person.fill", label: "Gender", value: character.gender.rawValue)
                Divider()
                DSInfoRow(icon: "leaf.fill", label: "Species", value: character.species)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

func locationCard(_ character: Character) -> some View {
    DSCard(padding: theme.spacing.xl) {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text(LocalizedStrings.locations)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)

            VStack(spacing: theme.spacing.md) {
                DSInfoRow(icon: "star.fill", label: "Origin", value: character.origin.name)
                Divider()
                DSInfoRow(icon: "mappin.circle.fill", label: "Last Known", value: character.location.name)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

---

## Header Section with Status

```swift
@Environment(\.dsTheme) private var theme

func headerSection(_ character: Character) -> some View {
    DSCard(padding: theme.spacing.xl) {
        VStack(spacing: theme.spacing.lg) {
            characterImage(character)
            nameAndStatus(character)
        }
        .frame(maxWidth: .infinity)
    }
}

func nameAndStatus(_ character: Character) -> some View {
    VStack(spacing: theme.spacing.sm) {
        Text(character.name)
            .font(theme.typography.title)
            .foregroundStyle(theme.colors.textPrimary)
            .multilineTextAlignment(.center)

        HStack(spacing: theme.spacing.sm) {
            DSStatusIndicator(status: DSStatus.from(character.status.rawValue), size: 10)

            Text(character.status.rawValue)
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textSecondary)

            Text("\u{2022}")
                .foregroundStyle(theme.colors.textTertiary)

            Text(character.species)
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
                .italic()
        }
    }
}
```

---

## Error View with Retry

```swift
var errorView: some View {
    DSErrorView(
        title: LocalizedStrings.Error.title,
        message: LocalizedStrings.Error.description,
        retryTitle: LocalizedStrings.Common.tryAgain
    ) {
        Task {
            await viewModel.load()
        }
    }
}
```

---

## Token Usage Examples

### Colors (via theme)

```swift
@Environment(\.dsTheme) private var theme

.background(theme.colors.backgroundPrimary)
.background(theme.colors.backgroundSecondary)
.foregroundStyle(theme.colors.textPrimary)
.foregroundStyle(theme.colors.textSecondary)
.foregroundStyle(theme.colors.statusSuccess)
```

### Spacing (via theme)

```swift
@Environment(\.dsTheme) private var theme

.padding(theme.spacing.lg)
.padding(.horizontal, theme.spacing.lg)
.padding(.vertical, theme.spacing.sm)

VStack(spacing: theme.spacing.md) { }
HStack(spacing: theme.spacing.sm) { }
```

### Typography (via theme)

```swift
@Environment(\.dsTheme) private var theme

Text("Title")
    .font(theme.typography.largeTitle)
    .foregroundStyle(theme.colors.textPrimary)

Text("Heading")
    .font(theme.typography.headline)
    .foregroundStyle(theme.colors.textPrimary)

Text("Body text")
    .font(theme.typography.body)
    .foregroundStyle(theme.colors.textPrimary)

Text("Caption")
    .font(theme.typography.caption)
    .foregroundStyle(theme.colors.textSecondary)
```

### Corners (via theme)

```swift
.clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
.clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.lg))
```

### Shadows (via theme)

```swift
@Environment(\.dsTheme) private var theme

.shadow(theme.shadow.small)
.shadow(theme.shadow.medium)
.shadow(theme.shadow.large)
```
