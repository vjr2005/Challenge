import ChallengeResources
import Foundation

/// Errors that can occur when working with characters.
public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
	case loadFailed
	case characterNotFound(identifier: Int)
	case invalidPage(page: Int)

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			return "characterError.loadFailed".localized()
		case .characterNotFound(let identifier):
			return "characterError.characterNotFound %lld".localized(identifier)
		case .invalidPage(let page):
			return "characterError.invalidPage %lld".localized(page)
		}
	}
}
