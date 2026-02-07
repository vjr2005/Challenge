import ChallengeResources
import Foundation

/// Errors that can occur when working with character detail.
public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
	case loadFailed
	case notFound(identifier: Int)

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			return "characterError.loadFailed".localized()
		case .notFound(let identifier):
			return "characterError.notFound %lld".localized(identifier)
		}
	}
}
