import ChallengeCore
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
				ForEach(viewModel.info.sections) { section in
					DSCard {
						VStack(spacing: theme.spacing.md) {
							ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
								if index > 0 {
									Divider()
								}
								DSInfoRow(
									icon: item.icon,
									label: item.title,
									value: item.description,
									accessibilityIdentifier: item.id
								)
							}
						}
					}
				}
			}
			.padding(theme.spacing.lg)
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
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
		.onFirstAppear {
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
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "about.title".localized() }
	static var appName: String { "about.appName".localized() }
	static var appDescription: String { "about.appDescription".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "about.scrollView"
	static let closeButton = "about.close.button"
	static let appIcon = "about.appIcon"
	static let appName = "about.appName"
	static let appDescription = "about.appDescription"
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
	let info: AboutInfo = GetAboutInfoUseCase().execute()
	func didAppear() {}
	func didTapClose() {}
}
#endif
*/
