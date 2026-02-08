import Testing

@testable import ChallengeCharacter

struct CharacterIncomingNavigationTests {
    // MARK: - Equatable

    @Test("Equality returns true for same list case")
    func equalityReturnsTrueForSameListCase() {
        #expect(CharacterIncomingNavigation.list == .list)
    }

    @Test("Equality returns true for detail cases with same identifier")
    func equalityReturnsTrueForDetailCasesWithSameIdentifier() {
        #expect(CharacterIncomingNavigation.detail(identifier: 42) == .detail(identifier: 42))
    }

    @Test("Equality returns false for detail cases with different identifier")
    func equalityReturnsFalseForDetailCasesWithDifferentIdentifier() {
        #expect(CharacterIncomingNavigation.detail(identifier: 42) != .detail(identifier: 99))
    }

    @Test("Equality returns true for advanced search cases regardless of delegate")
    func equalityReturnsTrueForAdvancedSearchCases() {
        // Given
        let delegate1 = CharacterFilterDelegateMock()
        let delegate2 = CharacterFilterDelegateMock()

        // Then
        #expect(CharacterIncomingNavigation.advancedSearch(delegate: delegate1) == .advancedSearch(delegate: delegate2))
    }

    @Test("Equality returns false for different cases")
    func equalityReturnsFalseForDifferentCases() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()

        // Then
        #expect(CharacterIncomingNavigation.list != .detail(identifier: 1))
        #expect(CharacterIncomingNavigation.list != .advancedSearch(delegate: delegateMock))
        #expect(CharacterIncomingNavigation.detail(identifier: 1) != .advancedSearch(delegate: delegateMock))
    }

    // MARK: - Hashable

    @Test("Hash values are equal for same cases")
    func hashValuesAreEqualForSameCases() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()

        // Then
        #expect(
            CharacterIncomingNavigation.list.hashValue == CharacterIncomingNavigation.list.hashValue
        )
        #expect(
            CharacterIncomingNavigation.detail(identifier: 42).hashValue == CharacterIncomingNavigation.detail(identifier: 42).hashValue
        )
        #expect(
            CharacterIncomingNavigation.advancedSearch(delegate: delegateMock).hashValue == CharacterIncomingNavigation.advancedSearch(delegate: delegateMock).hashValue
        )
    }

    @Test("Different cases produce different hash values")
    func differentCasesProduceDifferentHashValues() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()
        let set: Set<CharacterIncomingNavigation> = [
            .list,
            .detail(identifier: 1),
            .advancedSearch(delegate: delegateMock)
        ]

        // Then
        #expect(set.count == 3)
    }

    @Test("Detail cases with different identifiers produce different hash values")
    func detailCasesWithDifferentIdentifiersProduceDifferentHashValues() {
        // Given
        let set: Set<CharacterIncomingNavigation> = [
            .detail(identifier: 1),
            .detail(identifier: 2)
        ]

        // Then
        #expect(set.count == 2)
    }
}
