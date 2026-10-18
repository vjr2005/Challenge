import Testing

@testable import ChallengeCharacter

struct CharacterIncomingNavigationTests {
    // MARK: - Equatable

    @Test("Equality returns true for same list case")
    func equalityReturnsTrueForSameListCase() {
        // When
        let navigation = CharacterIncomingNavigation.list

        // Then
        #expect(navigation == .list)
    }

    @Test("Equality returns true for detail cases with same identifier")
    func equalityReturnsTrueForDetailCasesWithSameIdentifier() {
        // When
        let navigation = CharacterIncomingNavigation.detail(identifier: 42)

        // Then
        #expect(navigation == .detail(identifier: 42))
    }

    @Test("Equality returns false for detail cases with different identifier")
    func equalityReturnsFalseForDetailCasesWithDifferentIdentifier() {
        // When
        let navigation = CharacterIncomingNavigation.detail(identifier: 42)

        // Then
        #expect(navigation != .detail(identifier: 99))
    }

    @Test("Equality returns true for character filter cases regardless of delegate")
    func equalityReturnsTrueForCharacterFilterCases() {
        // Given
        let delegate1 = CharacterFilterDelegateMock()
        let delegate2 = CharacterFilterDelegateMock()

        // Then
        #expect(CharacterIncomingNavigation.characterFilter(delegate: delegate1) == .characterFilter(delegate: delegate2))
    }

    @Test("Equality returns false for different cases")
    func equalityReturnsFalseForDifferentCases() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()

        // Then
        #expect(CharacterIncomingNavigation.list != .detail(identifier: 1))
        #expect(CharacterIncomingNavigation.list != .characterFilter(delegate: delegateMock))
        #expect(CharacterIncomingNavigation.detail(identifier: 1) != .characterFilter(delegate: delegateMock))
    }

    // MARK: - Hashable

    @Test("Hash values are equal for same cases")
    func hashValuesAreEqualForSameCases() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()
        let navigations: [(lhs: CharacterIncomingNavigation, rhs: CharacterIncomingNavigation)] = [
            (.list, .list),
            (.detail(identifier: 42), .detail(identifier: 42)),
            (.characterFilter(delegate: delegateMock), .characterFilter(delegate: delegateMock))
        ]

        // Then
        for navigation in navigations {
            #expect(navigation.lhs.hashValue == navigation.rhs.hashValue)
        }
    }

    @Test("Different cases produce different hash values")
    func differentCasesProduceDifferentHashValues() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()
        let set: Set<CharacterIncomingNavigation> = [
            .list,
            .detail(identifier: 1),
            .characterFilter(delegate: delegateMock)
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
