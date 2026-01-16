import ChallengeCore
import SwiftUI

public enum CharacterFeature {
	private static let container = CharacterContainer()

	/// Builds the view for a navigation destination.
	/// Only used by App layer for `navigationDestination(for:)` registration.
	@ViewBuilder
	public static func view(for navigation: CharacterNavigation, router: RouterContract) -> some View {
		switch navigation {
		case .list:
			CharacterListView(viewModel: container.makeCharacterListViewModel(router: router))
		case .detail(let identifier):
			CharacterDetailView(viewModel: container.makeCharacterDetailViewModel(identifier: identifier, router: router))
		}
	}

	/// Returns the CharacterListView as the entry point for the Character feature.
	/// Used by App layer to display the initial view.
	public static func listView(router: RouterContract) -> some View {
		CharacterListView(viewModel: container.makeCharacterListViewModel(router: router))
	}
}
