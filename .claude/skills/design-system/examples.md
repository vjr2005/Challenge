# Design System Examples

## Complete View Using Design System

```swift
import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task { await viewModel.load() }
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
        case .error(let error):
            DSErrorView(
                title: LocalizedStrings.Error.title,
                message: error.localizedDescription
            )
        }
    }

    func characterList(page: CharactersPage) -> some View {
        ScrollView {
            LazyVStack(spacing: SpacingToken.lg) {
                headerView(totalCount: page.totalCount)

                ForEach(page.characters, id: \.id) { character in
                    CharacterRowView(character: character)
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
                }
            }
            .padding(.horizontal, SpacingToken.lg)
        }
        .background(ColorToken.backgroundSecondary)
    }

    func headerView(totalCount: Int) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            DSText(LocalizedStrings.headerTitle, style: .largeTitle)
            DSText(LocalizedStrings.headerSubtitle(totalCount), style: .subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

---

## Character Row Card

```swift
private struct CharacterRowView: View {
    let character: Character

    var body: some View {
        DSCard(padding: SpacingToken.lg) {
            HStack(spacing: SpacingToken.lg) {
                characterImage
                characterInfo
                Spacer()
                statusIndicator
            }
        }
    }

    private var characterImage: some View {
        DSAsyncImage(url: character.imageURL)
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
    }

    private var characterInfo: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs) {
            DSText(character.name, style: .headline)
                .lineLimit(1)

            Text(character.species)
                .font(TextStyle.subheadline.font)
                .foregroundStyle(ColorToken.textSecondary)

            HStack(spacing: SpacingToken.xs) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption2)
                Text(character.location.name)
                    .font(TextStyle.caption2.font)
            }
            .foregroundStyle(ColorToken.textTertiary)
        }
    }

    private var statusIndicator: some View {
        VStack(spacing: SpacingToken.xs) {
            DSStatusIndicator(status: DSStatus.from(character.status.rawValue))
            DSText(character.status.rawValue, style: .caption)
        }
    }
}
```

---

## Detail View with Cards

```swift
func infoCard(_ character: Character) -> some View {
    DSCard(padding: SpacingToken.xl) {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            DSText(LocalizedStrings.information, style: .headline)

            VStack(spacing: SpacingToken.md) {
                DSInfoRow(icon: "person.fill", label: "Gender", value: character.gender)
                Divider()
                DSInfoRow(icon: "leaf.fill", label: "Species", value: character.species)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

func locationCard(_ character: Character) -> some View {
    DSCard(padding: SpacingToken.xl) {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            DSText(LocalizedStrings.locations, style: .headline)

            VStack(spacing: SpacingToken.md) {
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
func headerSection(_ character: Character) -> some View {
    DSCard(padding: SpacingToken.xl) {
        VStack(spacing: SpacingToken.lg) {
            characterImage(character)
            nameAndStatus(character)
        }
        .frame(maxWidth: .infinity)
    }
}

func nameAndStatus(_ character: Character) -> some View {
    VStack(spacing: SpacingToken.sm) {
        DSText(character.name, style: .title)
            .multilineTextAlignment(.center)

        HStack(spacing: SpacingToken.sm) {
            DSStatusIndicator(status: DSStatus.from(character.status.rawValue), size: 10)

            Text(character.status.rawValue)
                .font(TextStyle.subheadline.font)
                .foregroundStyle(ColorToken.textSecondary)

            Text("•")
                .foregroundStyle(ColorToken.textTertiary)

            Text(character.species)
                .font(TextStyle.subheadline.font)
                .foregroundStyle(ColorToken.textSecondary)
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

### Colors

```swift
.background(ColorToken.backgroundPrimary)
.background(ColorToken.backgroundSecondary)
.foregroundStyle(ColorToken.textPrimary)
.foregroundStyle(ColorToken.textSecondary)
.foregroundStyle(ColorToken.statusSuccess)
```

### Spacing

```swift
.padding(SpacingToken.lg)
.padding(.horizontal, SpacingToken.lg)
.padding(.vertical, SpacingToken.sm)

VStack(spacing: SpacingToken.md) { }
HStack(spacing: SpacingToken.sm) { }
```

### Typography

```swift
DSText("Title", style: .largeTitle)
DSText("Heading", style: .headline)
DSText("Body text", style: .body)
DSText("Caption", style: .caption)

// Or use the font directly
.font(TextStyle.headline.font)
```

### Corners

```swift
.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.lg))
```

### Shadows

```swift
.shadow(.small)
.shadow(.medium)
.shadow(.large)
```
