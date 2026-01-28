@testable import ChallengeCharacter

extension CharacterListViewState: @retroactive Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading), (.empty, .empty):
			true
		case let (.loaded(lhsPage), .loaded(rhsPage)):
			lhsPage == rhsPage
		case let (.error(lhsError), .error(rhsError)):
			lhsError == rhsError
		default:
			false
		}
	}
}
