import ChallengeResources
import Foundation

/// Errors that can occur when loading paginated character lists.
public enum CharactersPageError: Error, Equatable, Sendable, LocalizedError {
	case loadFailed
	case invalidPage(page: Int)

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			"charactersPageError.loadFailed".localized()
		case .invalidPage(let page):
			"charactersPageError.invalidPage %lld".localized(page)
		}
	}
}
