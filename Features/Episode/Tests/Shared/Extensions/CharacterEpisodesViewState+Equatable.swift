@testable import ChallengeEpisode

extension CharacterEpisodesViewState: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading):
			true
		case let (.loaded(lhsData), .loaded(rhsData)):
			lhsData == rhsData
		case let (.error(lhsError), .error(rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}
