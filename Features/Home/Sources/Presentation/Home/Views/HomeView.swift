import ChallengeShared
import SwiftUI

struct HomeView<ViewModel: HomeViewModelContract>: View {
	/// Not @State: ViewModel has no observable state, just actions.
	let viewModel: ViewModel

	var body: some View {
		VStack(spacing: 20) {
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
    static let characterButton = "home.characterButton"
}

// MARK: - Previews

#Preview {
	HomeView(viewModel: HomeViewModelPreviewStub())
}

// MARK: - Preview Stubs

#if DEBUG
private final class HomeViewModelPreviewStub: HomeViewModelContract {
	func didTapOnCharacterButton() {}
}
#endif
