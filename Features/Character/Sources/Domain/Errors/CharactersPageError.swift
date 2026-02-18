import ChallengeResources
import Foundation

/// Errors that can occur when loading paginated character lists.
nonisolated public enum CharactersPageError: Error, Equatable, LocalizedError {
	case loadFailed(description: String = "")
	case invalidPage(page: Int)

	public static func == (lhs: CharactersPageError, rhs: CharactersPageError) -> Bool {
		switch (lhs, rhs) {
		case (.loadFailed, .loadFailed):
			true
		case let (.invalidPage(lhsPage), .invalidPage(rhsPage)):
			lhsPage == rhsPage
		default:
			false
		}
	}

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			"charactersPageError.loadFailed".localized()
		case .invalidPage(let page):
			"charactersPageError.invalidPage %lld".localized(page)
		}
	}
}

nonisolated extension CharactersPageError: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .loadFailed(let description):
			description
		case .invalidPage(let page):
			"invalidPage(page: \(page))"
		}
	}
}
