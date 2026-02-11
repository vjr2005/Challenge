import ChallengeDesignSystem
import ChallengeResources
import SwiftUI

struct AboutView<ViewModel: AboutViewModelContract>: View {
	let viewModel: ViewModel

	@Environment(\.dsTheme) private var theme

	var body: some View {
		ScrollView {
			VStack(spacing: theme.spacing.xl) {
				header
				featuresCard
				dependenciesCard
				creditsCard
			}
			.padding(theme.spacing.lg)
		}
		.background(theme.colors.backgroundSecondary)
		.navigationTitle(LocalizedStrings.title)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button {
					viewModel.didTapClose()
				} label: {
					Image(systemName: "xmark")
				}
				.accessibilityIdentifier(AccessibilityIdentifier.closeButton)
			}
		}
		.onAppear {
			viewModel.didAppear()
		}
	}
}

// MARK: - Subviews

private extension AboutView {
	var header: some View {
		VStack(spacing: theme.spacing.sm) {
			Image(systemName: "apple.terminal")
				.font(.system(size: theme.dimensions.xxl))
				.foregroundStyle(theme.colors.accent)
				.accessibilityIdentifier(AccessibilityIdentifier.appIcon)
			Text(LocalizedStrings.appName)
				.font(theme.typography.title2)
				.foregroundStyle(theme.colors.textPrimary)
				.accessibilityIdentifier(AccessibilityIdentifier.appName)
			Text(LocalizedStrings.appDescription)
				.font(theme.typography.caption)
				.foregroundStyle(theme.colors.textSecondary)
				.multilineTextAlignment(.center)
				.accessibilityIdentifier(AccessibilityIdentifier.appDescription)
		}
		.padding(.top, theme.spacing.lg)
	}

	var featuresCard: some View {
		DSCard {
			VStack(spacing: theme.spacing.md) {
				DSInfoRow(
					icon: "person.2",
					label: LocalizedStrings.featureBrowse,
					value: LocalizedStrings.featureBrowseValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureBrowseRow
				)
				Divider()
				DSInfoRow(
					icon: "magnifyingglass",
					label: LocalizedStrings.featureSearch,
					value: LocalizedStrings.featureSearchValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureSearchRow
				)
				Divider()
				DSInfoRow(
					icon: "line.3.horizontal.decrease.circle",
					label: LocalizedStrings.featureFilters,
					value: LocalizedStrings.featureFiltersValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureFiltersRow
				)
				Divider()
				DSInfoRow(
					icon: "person.text.rectangle",
					label: LocalizedStrings.featureDetail,
					value: LocalizedStrings.featureDetailValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureDetailRow
				)
				Divider()
				DSInfoRow(
					icon: "tv",
					label: LocalizedStrings.featureEpisodes,
					value: LocalizedStrings.featureEpisodesValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureEpisodesRow
				)
				Divider()
				DSInfoRow(
					icon: "arrow.triangle.2.circlepath",
					label: LocalizedStrings.featureNavigation,
					value: LocalizedStrings.featureNavigationValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureNavigationRow
				)
				Divider()
				DSInfoRow(
					icon: "globe",
					label: LocalizedStrings.featureLocalization,
					value: LocalizedStrings.featureLocalizationValue,
					accessibilityIdentifier: AccessibilityIdentifier.featureLocalizationRow
				)
			}
		}
	}

	var dependenciesCard: some View {
		DSCard {
			VStack(spacing: theme.spacing.md) {
				DSInfoRow(
					icon: "play.rectangle",
					label: LocalizedStrings.depLottie,
					value: LocalizedStrings.depLottieValue,
					accessibilityIdentifier: AccessibilityIdentifier.depLottieRow
				)
				Divider()
				DSInfoRow(
					icon: "camera.viewfinder",
					label: LocalizedStrings.depSnapshot,
					value: LocalizedStrings.depSnapshotValue,
					accessibilityIdentifier: AccessibilityIdentifier.depSnapshotRow
				)
				Divider()
				DSInfoRow(
					icon: "server.rack",
					label: LocalizedStrings.depMockServer,
					value: LocalizedStrings.depMockServerValue,
					accessibilityIdentifier: AccessibilityIdentifier.depMockServerRow
				)
			}
		}
	}

	var creditsCard: some View {
		DSCard {
			VStack(spacing: theme.spacing.md) {
				DSInfoRow(
					icon: "network",
					label: LocalizedStrings.api,
					value: LocalizedStrings.apiValue,
					accessibilityIdentifier: AccessibilityIdentifier.apiRow
				)
				Divider()
				DSInfoRow(
					icon: "person",
					label: LocalizedStrings.developer,
					value: LocalizedStrings.developerValue,
					accessibilityIdentifier: AccessibilityIdentifier.developerRow
				)
				Divider()
				DSInfoRow(
					icon: "wrench.and.screwdriver",
					label: LocalizedStrings.builtWith,
					value: LocalizedStrings.builtWithValue,
					accessibilityIdentifier: AccessibilityIdentifier.builtWithRow
				)
			}
		}
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "about.title".localized() }
	static var appName: String { "about.appName".localized() }
	static var appDescription: String { "about.appDescription".localized() }
	static var featureBrowse: String { "about.feature.browse".localized() }
	static var featureBrowseValue: String { "about.feature.browseValue".localized() }
	static var featureSearch: String { "about.feature.search".localized() }
	static var featureSearchValue: String { "about.feature.searchValue".localized() }
	static var featureFilters: String { "about.feature.filters".localized() }
	static var featureFiltersValue: String { "about.feature.filtersValue".localized() }
	static var featureDetail: String { "about.feature.detail".localized() }
	static var featureDetailValue: String { "about.feature.detailValue".localized() }
	static var featureEpisodes: String { "about.feature.episodes".localized() }
	static var featureEpisodesValue: String { "about.feature.episodesValue".localized() }
	static var featureNavigation: String { "about.feature.navigation".localized() }
	static var featureNavigationValue: String { "about.feature.navigationValue".localized() }
	static var featureLocalization: String { "about.feature.localization".localized() }
	static var featureLocalizationValue: String { "about.feature.localizationValue".localized() }
	static var depLottie: String { "about.dep.lottie".localized() }
	static var depLottieValue: String { "about.dep.lottieValue".localized() }
	static var depSnapshot: String { "about.dep.snapshot".localized() }
	static var depSnapshotValue: String { "about.dep.snapshotValue".localized() }
	static var depMockServer: String { "about.dep.mockServer".localized() }
	static var depMockServerValue: String { "about.dep.mockServerValue".localized() }
	static var api: String { "about.api".localized() }
	static var apiValue: String { "about.apiValue".localized() }
	static var developer: String { "about.developer".localized() }
	static var developerValue: String { "about.developerValue".localized() }
	static var builtWith: String { "about.builtWith".localized() }
	static var builtWithValue: String { "about.builtWithValue".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let closeButton = "about.close.button"
	static let appIcon = "about.appIcon"
	static let appName = "about.appName"
	static let appDescription = "about.appDescription"
	static let featureBrowseRow = "about.feature.browse"
	static let featureSearchRow = "about.feature.search"
	static let featureFiltersRow = "about.feature.filters"
	static let featureDetailRow = "about.feature.detail"
	static let featureEpisodesRow = "about.feature.episodes"
	static let featureNavigationRow = "about.feature.navigation"
	static let featureLocalizationRow = "about.feature.localization"
	static let depLottieRow = "about.dep.lottie"
	static let depSnapshotRow = "about.dep.snapshot"
	static let depMockServerRow = "about.dep.mockServer"
	static let apiRow = "about.api"
	static let developerRow = "about.developer"
	static let builtWithRow = "about.builtWith"
}

/*
// MARK: - Previews

#if DEBUG
#Preview("About") {
	NavigationStack {
		AboutView(viewModel: AboutViewModelPreviewStub())
	}
}

private final class AboutViewModelPreviewStub: AboutViewModelContract {
	func didAppear() {}
	func didTapClose() {}
}
#endif
*/
