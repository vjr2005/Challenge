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
		.onFirstAppear {
			viewModel.didAppear()
		}
	}
}

// MARK: - Subviews

private extension HomeView {
	var lottieAnimation: some View {
		LottieView(animation: .named("home", bundle: .home))
			.playbackMode(playbackMode)
			.animationDidFinish { _ in
				withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
					showButton = true
				}
			}
			.frame(height: 200)
			.accessibilityIdentifier(AccessibilityIdentifier.logoAnimation)
	}

	var characterButton: some View {
		Button {
			viewModel.didTapOnCharacterButton()
		} label: {
			Text(LocalizedStrings.goToCharacters)
		}
		.buttonStyle(.borderedProminent)
		.tint(theme.colors.accent)
		.accessibilityIdentifier(AccessibilityIdentifier.characterButton)
		.opacity(showButton ? 1 : 0)
		.scaleEffect(showButton ? 1 : 0.8)
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
}
#endif
*/
