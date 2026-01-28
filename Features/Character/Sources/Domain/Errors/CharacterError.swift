import ChallengeResources
import Foundation

/// Errors that can occur when working with characters.
public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
	case loadFailed
	case characterNotFound(id: Int)
	case invalidPage(page: Int)

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			return "characterError.loadFailed".localized()
		case .characterNotFound(let id):
			return "characterError.characterNotFound %lld".localized(id)
		case .invalidPage(let page):
			return "characterError.invalidPage %lld".localized(page)
		}
	}
}
