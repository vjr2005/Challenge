import ChallengeCharacter
import ChallengeCore
import ChallengeHome

/// Redirects outgoing navigation from features to their target feature navigation.
/// This is the central place where cross-feature navigation is defined.
public struct AppNavigationRedirect: NavigationRedirectContract {
	public init() {}

	public func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
		switch navigation {
		case let outgoing as HomeOutgoingNavigation:
			redirect(outgoing)
		default:
			nil
		}
	}

	// MARK: - Private

	private func redirect(_ navigation: HomeOutgoingNavigation) -> any NavigationContract {
		switch navigation {
		case .characters:
			CharacterIncomingNavigation.list
		}
	}
}
