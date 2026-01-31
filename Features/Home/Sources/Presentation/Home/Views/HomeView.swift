import ChallengeResources
import Lottie
import SwiftUI

struct HomeView<ViewModel: HomeViewModelContract>: View {
	let viewModel: ViewModel

	var body: some View {
		VStack(spacing: 20) {
			LottieView {
				try await DotLottieFile.named("home", bundle: .home)
			}
			.playing(loopMode: .loop)
			.frame(height: 200)
			.accessibilityIdentifier(AccessibilityIdentifier.logoAnimation)

			Text(LocalizedStrings.title)
				.font(.largeTitle)

			Button {
				viewModel.didTapOnCharacterButton()
			} label: {
				Text(LocalizedStrings.goToCharacters)
			}
			.buttonStyle(.borderedProminent)
			.accessibilityIdentifier(AccessibilityIdentifier.characterButton)
		}
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "home.title".localized() }
    static var goToCharacters: String { "home.goToCharacters".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let logoAnimation = "home.logoAnimation"
    static let characterButton = "home.characterButton"
}

// MARK: - Previews

#if DEBUG
#Preview {
	HomeView(viewModel: HomeViewModelPreviewStub())
}

private final class HomeViewModelPreviewStub: HomeViewModelContract {
	func didTapOnCharacterButton() {}
}
#endif
