@testable import ChallengeCharacter

final class CharacterFilterDelegateMock: CharacterFilterDelegate, @unchecked Sendable {
    var currentFilter: CharacterFilter = .empty
    private(set) var didApplyFilterCallCount = 0
    private(set) var lastAppliedFilter: CharacterFilter?

    @MainActor init() {}

    func didApplyFilter(_ filter: CharacterFilter) {
        didApplyFilterCallCount += 1
        lastAppliedFilter = filter
    }
}
