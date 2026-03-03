import ChallengeCore
import ChallengeDesignSystem
import ChallengeResources
import Lottie
import SwiftUI

struct HomeView<ViewModel: HomeViewModelContract>: View {
	let viewModel: ViewModel
	let playbackMode: LottiePlaybackMode

	@Environment(\.dsTheme) private var theme
	@State private var showButton: Bool

	init(
		viewModel: ViewModel,
		playbackMode: LottiePlaybackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)),
		showButton: Bool = false
	) {
		self.viewModel = viewModel
		self.playbackMode = playbackMode
		self._showButton = State(initialValue: showButton)
	}

	var body: some View {
		VStack(spacing: theme.spacing.xl) {
			lottieAnimation
			characterButton
		}
		.padding(theme.dimensions.xl)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					viewModel.didTapOnInfoButton()
				} label: {
					Image(systemName: "info.circle")
				}
				.accessibilityIdentifier(AccessibilityIdentifier.infoButton)
			}
		}
		.onFirstAppear {
			viewModel.didAppear()
		}
	}
}

// MARK: - Subviews

private extension HomeView {
	var lottieAnimation: some View {
		LottieView(animation: .named("home", bundle: .module))
			.playbackMode(playbackMode)
			.animationDidFinish { _ in
				withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
					showButton = true
				}
			}
			.frame(height: 200) // Lottie animation intrinsic height
			.accessibilityIdentifier(AccessibilityIdentifier.logoAnimation)
	}

	var characterButton: some View {
		DSButton(
			LocalizedStrings.goToCharacters,
			variant: .primary,
			accessibilityIdentifier: AccessibilityIdentifier.characterButton
		) {
			viewModel.didTapOnCharacterButton()
		}
		.opacity(showButton ? 1 : 0)
		.scaleEffect(showButton ? 1 : 0.8) // Spring scale for button reveal animation
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var goToCharacters: String { "home.goToCharacters".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let logoAnimation = "home.logoAnimation"
	static let characterButton = "home.characterButton"
	static let infoButton = "home.infoButton"
}

/*
// MARK: - Previews

#if DEBUG
#Preview {
	HomeView(viewModel: HomeViewModelPreviewStub())
}

private final class HomeViewModelPreviewStub: HomeViewModelContract {
	func didAppear() {}
	func didTapOnCharacterButton() {}
	func didTapOnInfoButton() {}
}
#endif
*/
