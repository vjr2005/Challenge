import ChallengeCommon
import ChallengeCore
import SwiftUI

struct HomeView: View {
	/// Not @State: ViewModel has no observable state, just actions.
	let viewModel: HomeViewModel

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
	HomeView(viewModel: HomeViewModel(router: RouterPreviewMock()))
}

// MARK: - Preview Mocks

private final class RouterPreviewMock: RouterContract {
	func navigate(to destination: any Navigation) {}
	func goBack() {}
}
